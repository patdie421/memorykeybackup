#include <stdio.h>

#include <CoreFoundation/CoreFoundation.h>

#include <IOKit/IOKitLib.h>
#include <IOKit/network/IOEthernetInterface.h>
#include <IOKit/network/IONetworkInterface.h>
#include <IOKit/network/IOEthernetController.h>


// #define D_DEBUG 1

kern_return_t findPrimaryEthernetInterfaces(io_iterator_t *matchingServices);
kern_return_t getMACAddress(io_iterator_t intfIterator, UInt8 *MACAddress);


// Returns an iterator containing the primary (built-in) Ethernet interface. The caller is responsible for
// releasing the iterator after the caller is done with it.
kern_return_t findPrimaryEthernetInterfaces(io_iterator_t *matchingServices)
{
    kern_return_t kernResult; 
    mach_port_t	masterPort;
    CFMutableDictionaryRef matchingDict;
    CFMutableDictionaryRef propertyMatchDict;
    
    // Retrieve the Mach port used to initiate communication with I/O Kit
    kernResult = IOMasterPort(MACH_PORT_NULL, &masterPort);
    if (KERN_SUCCESS != kernResult)
    {
#ifdef D_DEBUG
        fprintf(stderr,"IOMasterPort returned %d\n", kernResult);
#endif
        return kernResult;
    }
    
    // Ethernet interfaces are instances of class kIOEthernetInterfaceClass. 
    // IOServiceMatching is a convenience function to create a dictionary with the key kIOProviderClassKey and 
    // the specified value.
    matchingDict = IOServiceMatching(kIOEthernetInterfaceClass);
    
    // Note that another option here would be:
    // matchingDict = IOBSDMatching("en0");
    
    if (NULL != matchingDict)
    {
        // Each IONetworkInterface object has a Boolean property with the key kIOPrimaryInterface. Only the
        // primary (built-in) interface has this property set to TRUE.
        
        // IOServiceGetMatchingServices uses the default matching criteria defined by IOService. This considers
        // only the following properties plus any family-specific matching in this order of precedence 
        // (see IOService::passiveMatch):
        //
        // kIOProviderClassKey (IOServiceMatching)
        // kIONameMatchKey (IOServiceNameMatching)
        // kIOPropertyMatchKey
        // kIOPathMatchKey
        // kIOMatchedServiceCountKey
        // family-specific matching
        // kIOBSDNameKey (IOBSDNameMatching)
        // kIOLocationMatchKey
        
        // The IONetworkingFamily does not define any family-specific matching. This means that in            
        // order to have IOServiceGetMatchingServices consider the kIOPrimaryInterface property, we must
        // add that property to a separate dictionary and then add that to our matching dictionary
        // specifying kIOPropertyMatchKey.
        
        propertyMatchDict = CFDictionaryCreateMutable( kCFAllocatorDefault, 0,
                                                      &kCFTypeDictionaryKeyCallBacks,
                                                      &kCFTypeDictionaryValueCallBacks);
        
        if (NULL != propertyMatchDict)
        {
            // Set the value in the dictionary of the property with the given key, or add the key 
            // to the dictionary if it doesn't exist. This call retains the value object passed in.
            CFDictionarySetValue(propertyMatchDict, CFSTR(kIOPrimaryInterface), kCFBooleanTrue); 
            
            // Now add the dictionary containing the matching value for kIOPrimaryInterface to our main
            // matching dictionary. This call will retain propertyMatchDict, so we can release our reference 
            // on propertyMatchDict after adding it to matchingDict.
            CFDictionarySetValue(matchingDict, CFSTR(kIOPropertyMatchKey), propertyMatchDict);
            CFRelease(propertyMatchDict);
        }
#ifdef D_DEBUG
        else
        {
            fprintf(stderr,"CFDictionaryCreateMutable returned a NULL dictionary.\n");
        }
#endif
    }
#ifdef D_DEBUG
    else
    {
        fprintf(stderr,"IOServiceMatching returned a NULL dictionary.\n");
    }
#endif
    
    // IOServiceGetMatchingServices retains the returned iterator, so release the iterator when we're done with it.
    // IOServiceGetMatchingServices also consumes a reference on the matching dictionary so we don't need to release
    // the dictionary explicitly.
    kernResult = IOServiceGetMatchingServices(masterPort, matchingDict, matchingServices);    
    if (KERN_SUCCESS != kernResult)
    {
#ifdef D_DEBUG
        fprintf(stderr,"IOServiceGetMatchingServices returned %d\n", kernResult);
#endif
    }
    
    return kernResult;
}

// Given an iterator across a set of Ethernet interfaces, return the MAC address of the last one.
// If no interfaces are found the MAC address is set to an empty string.
// In this sample the iterator should contain just the primary interface.
kern_return_t getMACAddress(io_iterator_t intfIterator, UInt8 *MACAddress)
{
    io_object_t		intfService;
    io_object_t		controllerService;
    kern_return_t	kernResult = KERN_FAILURE;
    
    // Initialize the returned address
    bzero(MACAddress, kIOEthernetAddressSize);
    
    // IOIteratorNext retains the returned object, so release it when we're done with it.
    while (intfService = IOIteratorNext(intfIterator))
    {
        CFTypeRef	MACAddressAsCFData;        
        
        // IONetworkControllers can't be found directly by the IOServiceGetMatchingServices call, 
        // since they are hardware nubs and do not participate in driver matching. In other words,
        // registerService() is never called on them. So we've found the IONetworkInterface and will 
        // get its parent controller by asking for it specifically.
        
        // IORegistryEntryGetParentEntry retains the returned object, so release it when we're done with it.
        kernResult = IORegistryEntryGetParentEntry( intfService,
                                                    kIOServicePlane,
                                                    &controllerService );
        if (KERN_SUCCESS == kernResult)
        {
            // Retrieve the MAC address property from the I/O Registry in the form of a CFData
            MACAddressAsCFData = IORegistryEntryCreateCFProperty( controllerService,
                                                                 CFSTR(kIOMACAddress),
                                                                 kCFAllocatorDefault,
                                                                 0);
            if (MACAddressAsCFData)
            {
#ifdef D_DEBUG
                CFShow(MACAddressAsCFData); // for display purposes only; output goes to stderr
#endif                
                // Get the raw bytes of the MAC address from the CFData
                CFDataGetBytes(MACAddressAsCFData, CFRangeMake(0, kIOEthernetAddressSize), MACAddress);
                CFRelease(MACAddressAsCFData);
            }
            
            // Done with the parent Ethernet controller object so we release it.
            (void) IOObjectRelease(controllerService);
        }
#ifdef D_DEBUG
        else
        {
            fprintf(stderr,"IORegistryEntryGetParentEntry returned 0x%08x\n", kernResult);
        }
#endif
        // Done with the Ethernet interface object so we release it.
        (void) IOObjectRelease(intfService);
    }
    
    return kernResult;
}


int adresseMac(UInt8 MACAddress[])
{
    kern_return_t	kernResult = KERN_SUCCESS; // on PowerPC this is an int (4 bytes)
    
    /*
     *	error number layout as follows (see mach/error.h and IOKit/IOReturn.h):
     */
    io_iterator_t	intfIterator;
    
    kernResult = findPrimaryEthernetInterfaces(&intfIterator);
    if (KERN_SUCCESS == kernResult)
    {
        kernResult = getMACAddress(intfIterator, MACAddress);
#ifdef D_DEBUG        
        if (KERN_SUCCESS != kernResult)
        {
            fprintf(stderr,"GetMACAddress returned 0x%08x\n", kernResult);
        }
#endif
    }
#ifdef D_DEBUG
    else
    {
        fprintf(stderr,"FindEthernetInterfaces returned 0x%08x\n", kernResult);
    }
#endif
    IOObjectRelease(intfIterator);	// Release the iterator.

    return kernResult;
}


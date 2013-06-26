#import <Cocoa/Cocoa.h>

#import "general.h"


NSString *c_defaults=@"defaults2";

NSString *c_idcle=@"IDCLE";
NSString *c_desccle=@"DESCCLE";
NSString *c_init=@"INIT";
NSString *c_dernsauv=@"DERNSAUV";
NSString *c_sauvsuiv=@"SAUVSUIV";
NSString *c_typesauv=@"TYPESAUV";
NSString *c_backdir=@"BACKDIR";
NSString *c_kstatus=@"KSTATUS";
NSString *c_maxkeysize=@"MAXKEYSIZE";

NSString *c_datafile=@"~/Applications/USBKeyBackup/USBKeyBackup.plist";

NSString *c_backuptype=@"BACKUPTYPE";
NSString *c_actioninsersion=@"ACTIONINSERTION";
NSString *c_actioninsersion_nb=@"ACTIONINSERTION_NB";
NSString *c_actioninsersion_unite=@"ACTIONINSERTION_UNITE";
NSString *c_planning=@"PLANNING";
NSString *c_planning_nb=@"PLANNING_NB";
NSString *c_planning_unite=@"PLANNING_UNITE";
NSString *c_autodeclaration=@"AUTODECLARATION";
NSString *c_advanced=@"AVANCED_OPTIONS";
NSString *c_fichierTag=@".USBKeyBackup";

NSString *c_listeColonnes=@"listeColonnes";
NSString *c_tailleColonnes=@"tailleColonnes";

NSString *c_detection=@"DETECTION";
NSString *c_msdos=@"msdos";
NSString *c_hfs=@"hfs";
NSString *c_ntfs=@"ntfs";
NSString *c_afpfs=@"afpfs";
NSString *c_otherfs=@"otherfs";
NSString *c_nodmci=@"nodmci";
NSString *c_notkey=@"notkey";

NSString *c_notifDebutTacheSauvegarde=@"NTFDTS";
NSString *c_notifFinTacheSauvegarde=@"NTFFTS";
NSString *c_notifChangementTacheSauvegarde=@"NTCTS";

NSString *c_notifLancementTache=@"NTFSTRTTSK";
NSString *c_notifFinTache=@"NTFENDTSK";
NSString *c_notifErreurTache=@"NTFERRTSK";
NSString *c_notifClePlanifiee=@"NTFCLEPLANIFIEE";
NSString *c_notifCleDeplanifiee=@"NTFCLEDEPLANIFIEE";
NSString *c_notifDemarrageSauvegarde=@"NTFSTRTBAK";
NSString *c_notifEnregistrement=@"NTFREC";

NSString *c_notifAJournaliser=@"NTFLOG";

NSString *c_notifDemarrageRestauration=@"NTFSTRRST";
NSString *c_notifChangementRestauration=@"NTFCHGRST";
NSString *c_notifFinRestauration=@"NTFENDNRST";

static double marque[]={256,1024,4096,8192,32768,65536,1114112};
static double arrondi[]={32,512,512,1024,4096,4096,16384};


double tailleEnFonctionDePositionSlider(double position)
{
    int unEntier;
    double taille;
    
    unEntier=(int)position;
    
    if(unEntier == 6)
        taille=-1; // pas de limite
    else
    {
        taille = marque[unEntier] + (position-(double)unEntier)*(marque[unEntier+1]-marque[unEntier]);
        taille = (double)((long)(taille/arrondi[unEntier])) * arrondi[unEntier];
    }
    
    return taille;
}


double positionSliderEnFonctionDeTaille(double taille)
{
    int i;
    
    if(taille<0)
        return 6;
    
    for(i=0;i<6;i++)
    {
        if(taille<=marque[i+1])
            break;
    }
    
    return (i+(taille-marque[i])/(marque[i+1]-marque[i]));
}




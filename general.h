#import <Cocoa/Cocoa.h>


extern NSString *c_defaults;
extern NSString *c_idcle;
extern NSString *c_desccle;
extern NSString *c_init;
extern NSString *c_dernsauv;
extern NSString *c_sauvsuiv;
extern NSString *c_typesauv;
extern NSString *c_backdir;
extern NSString *c_kstatus;
extern NSString *c_maxkeysize;

extern NSString *c_datafile;

extern NSString *c_backuptype;
extern NSString *c_actioninsersion;
extern NSString *c_actioninsersion_nb;
extern NSString *c_actioninsersion_unite;
extern NSString *c_planning;
extern NSString *c_planning_nb;
extern NSString *c_planning_unite;
extern NSString *c_autodeclaration;
extern NSString *c_advanced;

extern NSString *c_fichierTag;

extern NSString *c_listeColonnes;
extern NSString *c_tailleColonnes;

extern NSString *c_detection;
extern NSString *c_msdos;
extern NSString *c_hfs;
extern NSString *c_ntfs;
extern NSString *c_afpfs;
extern NSString *c_otherfs;
extern NSString *c_nodmci;
extern NSString *c_notkey;

extern NSString *c_notifChangementTacheSauvegarde;
extern NSString *c_notifDebutTacheSauvegarde;
extern NSString *c_notifFinTacheSauvegarde;

extern NSString *c_notifLancementTache;

extern NSString *c_notifFinTache;
extern NSString *c_notifErreurTache;
extern NSString *c_notifClePlanifiee;
extern NSString *c_notifCleDeplanifiee;
extern NSString *c_notifDemarrageSauvegarde;
extern NSString *c_notifEnregistrement;

extern NSString *c_notifAJournaliser;

extern NSString *c_notifDemarrageRestauration;
extern NSString *c_notifChangementRestauration;
extern NSString *c_notifFinRestauration;

#define D_DEBUG 1
#ifdef D_DEBUG
#define DEBUGNSLOG(...) NSLog(__VA_ARGS__)
#else
#define DEBUGNSLOG(...)
#endif

#define D_DEFAULTS c_defaults
#define D_IDCLE    c_idcle
#define D_DESCCLE  c_desccle
#define D_INIT     c_init
#define D_DERNSAUV c_dernsauv
#define D_SAUVSUIV c_sauvsuiv
#define D_TYPESAUV c_typesauv
#define D_BACKDIR  c_backdir
#define D_KSTATUS  c_kstatus
#define D_MAXKEYSIZE c_maxkeysize

#define D_DATAFILE c_datafile

#define D_BACKUPTYPE c_backuptype
#define D_ACTIONINSERSION c_actioninsersion
#define D_ACTIONINSERSION_NB c_actioninsersion_nb
#define D_ACTIONINSERSION_UNITE c_actioninsersion_unite
#define D_PLANNING c_planning
#define D_PLANNING_NB c_planning_nb
#define D_PLANNING_UNITE c_planning_unite
#define D_AUTODECLARATION c_autodeclaration
#define D_ADVANCED c_advanced

#define D_FICHIERTAG c_fichierTag

#define D_LISTECOLONNES c_listeColonnes
#define D_TAILLECOLONNES c_tailleColonnes

#define D_DETECTION c_detection
#define D_MSDOS c_msdos
#define D_HFS c_hfs
#define D_NTFS c_ntfs
#define D_AFPFS c_afpfs
#define D_OTHERFS c_otherfs

#define D_NODMCI c_nodmci
#define D_NOTKEY c_notkey

#define D_NOTIFDEBUTTACHESAUVEGARDE c_notifDebutTacheSauvegarde
#define D_NOTIFFINTACHESAUVEGARDE c_notifFinTacheSauvegarde
#define D_NOTIFICHANGEMENTTACHESAUVEGARDE c_notifChangementTacheSauvegarde
#define D_NOTIFLANCEMENTTACHE c_notifLancementTache
#define D_NOTIFFINTACHE c_notifFinTache
#define D_NOTIFERREURTACHE c_notifErreurTache
#define D_NOTIFCLEPLANIFIEE c_notifClePlanifiee
#define D_NOTIFCLEDEPLANIFIEE c_notifCleDeplanifiee
#define D_NOTIFDEMARRAGESAUVEGARDE c_notifDemarrageSauvegarde
#define D_NOTIFENREGISTREMENT c_notifEnregistrement

#define D_NOTIFAJOURNALISER c_notifAJournaliser

#define D_NOTIFDEMARRAGERESTAURATION c_notifDemarrageRestauration
#define D_NOTIFCHANGEMENTRESTAURATION c_notifChangementRestauration
#define D_NOTIFFINRESTAURATION c_notifFinRestauration

double tailleEnFonctionDePositionSlider(double position);
double positionSliderEnFonctionDeTaille(double taille);


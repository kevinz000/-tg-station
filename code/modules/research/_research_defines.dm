
//RDSCREEN screens
#define RDSCREEN_MENU 0
#define RDSCREEN_TECHDISK 1
#define RDSCREEN_DESIGNDISK 20
#define RDSCREEN_DESIGNDISK_UPLOAD 21
#define RDSCREEN_DECONSTRUCT 3
#define RDSCREEN_PROTOLATHE 40
#define RDSCREEN_PROTOLATHE_MATERIALS 41
#define RDSCREEN_PROTOLATHE_CHEMICALS 42
#define RDSCREEN_PROTOLATHE_CATEGORY_VIEW 43
#define RDSCREEN_PROTOLATHE_SEARCH 44
#define RDSCREEN_IMPRINTER 50
#define RDSCREEN_IMPRINTER_MATERIALS 51
#define RDSCREEN_IMPRINTER_CHEMICALS 52
#define RDSCREEN_IMPRINTER_CATEGORY_VIEW 53
#define RDSCREEN_IMPRINTER_SEARCH 54
#define RDSCREEN_SETTINGS 61
#define RDSCREEN_DEVICE_LINKING 62
#define RDSCREEN_TECHWEB 70
#define RDSCREEN_TECHWEB_NODEVIEW 71
#define RDSCREEN_TECHWEB_DESIGNVIEW 72

#define RDSCREEN_NOBREAK "<NO_HTML_BREAK>"

#define RDSCREEN_TEXT_NO_PROTOLATHE "<div><h3>No Protolathe Linked!</h3></div><br>"
#define RDSCREEN_TEXT_NO_IMPRINTER "<div><h3>No Circuit Imprinter Linked!</h3></div><br>"
#define RDSCREEN_TEXT_NO_DECONSTRUCT "<div><h3>No Deconstructive Analyzer Linked!</h3></div><br>"
#define RDSCREEN_TEXT_NO_TDISK "<div><h3>No Technology Disk Inserted!</h3></div><br>"
#define RDSCREEN_TEXT_NO_DDISK "<div><h3>No Design Disk Inserted!</h3></div><br>"
#define RDSCREEN_TEXT_NO_SNODE "<div><h3>No Technology Node Selected!</h3></div><br>"
#define RDSCREEN_TEXT_NO_SDESIGN "<div><h3>No Design Selected!</h3></div><br>"

#define RDSCREEN_UI_LATHE_CHECK if(!linked_lathe) { return RDSCREEN_TEXT_NO_PROTOLATHE }
#define RDSCREEN_UI_IMPRINTER_CHECK if(!linked_imprinter) { return RDSCREEN_TEXT_NO_IMPRINTER }
#define RDSCREEN_UI_DECONSTRUCT_CHECK if(!linked_destroy) { return RDSCREEN_TEXT_NO_DECONSTRUCT }
#define RDSCREEN_UI_TDISK_CHECK if(!t_disk) { return RDSCREEN_TEXT_NO_TDISK }
#define RDSCREEN_UI_DDISK_CHECK if(!d_disk) { return RDSCREEN_TEXT_NO_DDISK }
#define RDSCREEN_UI_SNODE_CHECK if(!selected_node) { return RDSCREEN_TEXT_NO_SNODE }
#define RDSCREEN_UI_SDESIGN_CHECK if(!selected_design) { return RDSCREEN_TEXT_NO_SDESIGN }

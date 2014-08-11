#define MAX_BANK_CNT 8
#define MAX_DISTANCE_CNT  5

#define SETTING_FILE_NAME @"setting.plist"

#define BANK_KEY  @"Bank_Key"
#define DISTANCE_KEY @"Distance_Key"

typedef enum
{
	ERRORCANTFINDLOCATION = 1000,
	ERRORUNKNOWNADDRESS = 1001,
	ERRORCANTTRANSLATETOADDRESS = 1002
} LOCATIONERROR;
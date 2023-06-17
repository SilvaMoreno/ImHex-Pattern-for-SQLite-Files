#pragma MIME application/vnd.sqlite3

struct SQLiteHeader {
    char Magic[15];
    padding[1];
    u16 PageSize;
    u8 FileFormatWrite;
    u8 FileFormatRead;
    u8 SizeReservedForExtensionsPerPage;
    u8 MaximumPayloadFraction;
    u8 MinimumPayloadFraction;
    u8 PayloadFraction;
    be u32 FileChangeCounter;
    be u32 InHeaderDatabaseSize;
    be u32 FirstFreePageList;
    be u32 TotalFreePageList;
    be u32 SchemaCookie;
    be u32 SchemaFormatNumber;
    be u32 CacheSize;
    be u32 PageNumberLargestRootPage;
    be u32 TextEncoding;
};

struct SQLiteStruct {
    SQLiteHeader Header;
    s64 lineLength;
};

SQLiteStruct Database @ 0x00;

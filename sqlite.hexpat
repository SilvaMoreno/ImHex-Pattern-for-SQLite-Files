#pragma MIME application/x-sqlite3

struct SQLiteHeader {
    char Magic[15];
    padding[1];
    be u16 PageSize;
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
    be u32 UserVersionNumber;
    be u32 IncrementalVacuumMode;
    be u32 ApplicationID;
    padding[20];
    be u32 VersionChangeNumber;
    be u32 VersionNumber;
};

struct SQLiteStruct {
    SQLiteHeader Header;
    s64 lineLength;
};

SQLiteStruct Database @ 0x00;

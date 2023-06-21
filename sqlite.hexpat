#pragma MIME application/x-sqlite3
#pragma endian big

#include <std/io.pat>
#include <std/mem.pat>

using BTreePage;

u32 pageSize = 0;

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
    u32 FileChangeCounter;
    u32 InHeaderDatabaseSize;
    u32 FirstFreePageList;
    u32 TotalFreePageList;
    u32 SchemaCookie;
    u32 SchemaFormatNumber;
    u32 CacheSize;
    u32 PageNumberLargestRootPage;
    u32 TextEncoding;
    u32 UserVersionNumber;
    u32 IncrementalVacuumMode;
    u32 ApplicationID;
    padding[20];
    u32 VersionChangeNumber;
    u32 VersionNumber;
};

enum BTreePageType: u8 {
    InteriorIndex = 0x02,
    InteriorTable = 0x05,
    LeafIndex = 0x0a,
    LeafTable = 0x0d
};

struct BTreePageHeader {
    BTreePageType Type;
    u16 OffsetToFirstFreeblockPage;
    u16 NumberOfCells;
    u16 OffsetToCellContentArea;
    u8 FragmentedBytes;
    
    if(Type == BTreePageType::InteriorIndex || Type == BTreePageType::InteriorTable){
        u32 RightMostPointer;
    }
};


struct CellsInteriorIndex {
    // u16 cellPointer;
    // u32 LeftPointer @ cellPointer;
    // u8 Key @ cellPointer + 4;
    std::print("Interior Index Not implemented");

};

struct CellsLeafIndex {
    // u16 cellPointer;
    // u32 LeftPointer @ cellPointer;
    // u8 Key @ cellPointer + 4;
    std::print("Leaf Index Not implemented");
};

struct CellsInteriorTable {
    u16 cellPointer;
    u32 LeftPointer @ cellPointer;
    u8 Key @ cellPointer + 4;
    
    u32 offset = pageSize * (LeftPointer - 1);
    std::print("Interior table offset {}", offset);
    // BTreePageHeader Header @ size;
    BTreePage Page @ offset;
};

struct CellsLeafTable {
    u32 offset = addressof(this);
    u16 cellPointer;
    u8 byteSofPayload @ cellPointer;
    u8 Key @ cellPointer + 1;
    u8 Payload @ cellPointer + 2;
    u32 PageNumber @ cellPointer + 3;

    // u32 size = pageSize * (LeftPointer - 1);
   std::print("offset {}, cellPointer= {}", offset, cellPointer);
   // BTreePageHeader Header @ size;
   //BTreePage Page @ size;
   u32 test @ cellPointer + offset;
};



struct BTreePage {
    BTreePageHeader Header;
     
    std::print("Number of Cell {}", Header.NumberOfCells);
    // Cells cellPointer[NumberOfCells];
    match (Header.Type) {
        (BTreePageType::InteriorIndex): {
            CellsInteriorIndex CellsInteriorIndex[Header.NumberOfCells];
        }
        (BTreePageType::LeafIndex): {
            CellsLeafIndex CellsLeafIndex[Header.NumberOfCells];
        }
        (BTreePageType::InteriorTable): {
            CellsInteriorTable CellsInteriorTable[Header.NumberOfCells];
        }
        (BTreePageType::LeafTable): {
            CellsLeafTable CellsLeafTable[Header.NumberOfCells];
        }
    } 
};

SQLiteHeader Header @ 0x00;
pageSize = Header.PageSize;
BTreePage Page @ 0x64; // 100
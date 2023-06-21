#pragma MIME application/x-sqlite3
#pragma endian big
#pragma array_limit 655363334

#include <std/io.pat>
#include <type/leb128.pat>
#include <std/mem.pat>

using btree_page;

u32 len_page = 0x10000;

enum Version: u8 {
    legacy = 1,
    wal = 2
};

enum Encode: u32 {
    utf_8 = 1,
    utf_16le = 2,
    utf_16be = 3
};

enum PageType: u8 {
     cell_table_leaf = 0x0d,
     cell_table_interior = 0x05,
     cell_index_leaf = 0x0a,
     cell_index_interior = 0x02
};

struct cell_payload {
    type::uLEB128 len_header_and_len;
   // type::uLEB128 column_serials[len_header_and_len - 1];
};


// ------------------
struct table_leaf {
 type::uLEB128 len_payload;
 type::uLEB128 row_id;
 cell_payload payload[len_payload];
};

struct cell_table_leaf {
    u16 ofs_body;
    
    table_leaf cell @ ofs_body;    
};

// ------------------
struct table_interior {
    u32 left_child_page;
    type::uLEB128 row_id;
    
    u32 offset = len_page * (left_child_page - 1);
    
     btree_page pages @ offset;
};

struct cell_table_interior {
    u16 ofs_body;
    
    table_interior cell @ ofs_body;
};

// ------------------
struct btree_page {
    PageType page_type;
    u16 first_freeblock;
    u16 num_cells;
    u16 ofs_cells;
    u8 num_frag_free_bytes;
    
    if (page_type == PageType::cell_table_interior || page_type == PageType::cell_index_interior){
        u32 right_ptr;
    }
    
    match (page_type) {
        (PageType::cell_table_leaf): {
            // type::uLEB128 len_payload @  cells[0].ofs_body;
            // type::uLEB128  row_id;
            cell_table_leaf cell[num_cells];
        }
        (PageType::cell_table_interior): {
            cell_table_interior cell[num_cells];
        }
        (PageType::cell_index_leaf): {}
        (PageType::cell_index_interior): {}
        
    }
};
    
struct database_header {
    char magic[16];
    // The database page size in bytes. Must be a power of two between 512 and 32768 inclusive, or the value 1 representing a page size of 65536
    u16 len_page_mod;
    Version write_version;
    Version read_version;
    // Bytes of unused "reserved" space at the end of each page. Usually 0
    u8 reserved_space;
    // Maximum embedded payload fraction. Must be 64
    u8 max_payload_frac;
    // Minimum embedded payload fraction. Must be 32
    u8 min_payload_frac;
    // Leaf payload fraction. Must be 32
    u8 leaf_payload_frac;
    u32 file_change_counter;
    // Size of the database file in pages. The "in-header database size"
    u32 num_pages;
    // Page number of the first freelist trunk page
    u32 first_freelist_trunk_page;
    // Total number of freelist pages
    u32 num_freelist_pages;
    u32 schema_cookie;
    // The schema format number. Supported schema formats are 1, 2, 3, and 4
    u32 schema_format;
    // Default page cache size
    u32 def_page_cache_size;
    // The page number of the largest root b-tree page when in auto-vacuum or incremental-vacuum modes, or zero otherwise
    u32 largest_root_page;
    Encode text_encoding;
    // The "user version" as read and set by the user_version pragma
    u32 user_version;
    
    // True (non-zero) for incremental-vacuum mode. False (zero) otherwise
    u32 is_incremental_vacuum;
    
    u32 application_id;
    
    // reserved
    padding[20];
    
    u32 version_valid_for;
    u32 sqlite_version_number;
    
    if (len_page_mod == 1) {
        len_page = 0x10000;
     } else {
        len_page = len_page_mod;
     }
};

struct file {
    database_header header;
    btree_page pages;
};

file SQLite @ 0x00;
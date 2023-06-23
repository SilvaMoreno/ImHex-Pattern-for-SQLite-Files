#pragma MIME application/x-sqlite3
#pragma endian big
#pragma array_limit 1310727789
#pragma pattern_limit 13109087

#include <std/io.pat>
#include <type/leb128.pat>
#include <type/base.pat>
#include <std/mem.pat>
#include <std/math.pat>
#include <std/core.pat>
#include <std/string.pat>


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

fn decimalToBinary(s32 num) {   
    if (num == 0) {
        return "0000000";
    }
   
   u32 binaryNum[32]; 
   u32 i = 0;
   
   while (num > 0) {
      binaryNum[i] = num % 2;
      num = num / 2;
      i = i + 1;
   }
   
   char binary[8];
   

   for (s32 j = i-1, j >= 0, j = j - 1) {
      std::print("binary = {}", binaryNum[j]);
      //binary[1] = std::string::to_string(binaryNum[j]);
    }
    
      std::print("binary = {}", binaryNum);
};


fn read_varint(u32 offset) {
    u32 index = 0;
    u32 current_offset = offset;
    
    u32 values[9];
    u32 values_offset[9];
    
    while(current_offset != 0) {
        u8 varint = std::mem::read_unsigned(current_offset, 1, std::core::get_endian());
        values[index] = varint;
        values_offset[index] = current_offset;
        type::Bin<u8> binNumber = varint;
        //decimalToBinary(varint);
        //std::print("binNumber = {}", binNumber);
        //std::print("varint indix {}  = {}", index, varint);
        
        if (varint < 0x80) {
              current_offset = 0;
        } else {
             current_offset = current_offset + 1;
        }
        index = index + 1;
    }
     //std::print("values = {} ", values);
     //std::print("index= {} ", index);
    
    u32 value;
    
    for (u8 i = 0, i <= index - 1, i = i + 1) {
         //std::print("i = {} ", i);
        if (index <= 3) {
            if (i == index - 1) {
                value = value + values[i];
            } else {
                value = value + ((values[i] - 0x80) * std::math::pow(0x80, i  +1));
            }
        } else {
            value = value + ((values[i] - 0x80) * std::math::pow(0x80, i +1));
        }
        
         //std::print("value on index {} val {} = {} ", i, values[i], value);
    }
    
   // std::print("value total = {} ", value);
    
    return value;
    
};



struct cell_payload {
     
    //type::uLEB128 len_header_and_len;
    // u32 real_len_header_and_len = read_varint(addressof(this));
     //std::print("real_len_header_and_len= {}", real_len_header_and_len);
    
    u16 count = std::mem::read_unsigned(addressof(this), 1, std::core::get_endian());
    std::print("count array payload {}", count);
    //type::uLEB128 header[count];
    u8 header[count];

        //if (len_header_and_len < 2) {
    //type::uLEB128 column_serials[len_header_and_len - 1];
    //}
};


// ------------------
struct table_leaf {
     type::uLEB128 len_payload;
     
     u32 real_len_payload = read_varint(addressof(this));
     std::print("real_len_payload = {}", real_len_payload);
     
     type::uLEB128 row_id;
     
     //u32 real_len_header_and_len = read_varint(addressof(this));
     //std::print("real_len_header_and_len= {}", real_len_header_and_len);
     
        
    u16 count = std::mem::read_unsigned(addressof(this), 1, std::core::get_endian());
    std::print("olaee {}", count);
     
    cell_payload payload;
    //type::uLEB128 header[real_len_header_and_len];
    
   // 
     
    char content[real_len_payload];
    
    u32 overflow_page;
};

struct cell_table_leaf {
    u32 start_of_page = addressof(this) - 8;
    if (start_of_page < 512) {
        start_of_page = 0;
    }
    std::print("start cell_table_leaf: {}", start_of_page);
    u16 ofs_body;
    
    table_leaf body @ start_of_page + ofs_body;    
};

// ------------------ cell_index_leaf
struct index_leaf {
     type::uLEB128 len_payload;
     
     u32 real_len_payload = read_varint(addressof(this));
     std::print("real_len_payload = {}", real_len_payload);
     
     //type::uLEB128 row_id;
     
     //u32 real_len_header_and_len = read_varint(addressof(this));
     //std::print("real_len_header_and_len= {}", real_len_header_and_len);
     
        
    u16 count = std::mem::read_unsigned(addressof(this), 1, std::core::get_endian());
    std::print("olaee {}", count);
     
    cell_payload payload;
    //type::uLEB128 header[real_len_header_and_len];
    
   // 
     
    char content[real_len_payload];
    
    u32 overflow_page;
};

struct cell_index_leaf {
    u32 start_of_page = addressof(this) - 8;
    if (start_of_page < 512) {
        start_of_page = 0;
    }
    std::print("start cell_table_leaf: {}", start_of_page);
    u16 ofs_body;
    
    index_leaf body @ start_of_page + ofs_body;    
};

// ------------------
struct table_interior {
    u32 left_child_page;
    type::uLEB128 row_id;
    
    u32 offset = len_page * (left_child_page - 1);
    
    btree_page page @ offset;
};

struct cell_table_interior {
    u16 ofs_body;
    
    table_interior body @ ofs_body;
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
            cell_table_leaf cells[num_cells];
        }
        (PageType::cell_table_interior): {
            cell_table_interior cells[num_cells];
        }
        (PageType::cell_index_leaf): {
            cell_index_leaf cells[num_cells];
            //std::print("Not implimented cell_index_leaf");
        }
        (PageType::cell_index_interior): {
            std::print("Not implimented cell_index_leaf");
        }
        
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
    btree_page root_page;  
    
    btree_page page1 @ len_page;
    btree_page page2 @ len_page * 2;
    btree_page page3 @ len_page * 3;
    btree_page page4 @ len_page * 4;
    btree_page page5 @ len_page * 5;
    //btree_page page6 @ len_page * 6;
    // u8 nun = 3;
};

file SQLite @ 0x00;
// u32 ddd @ 69607;
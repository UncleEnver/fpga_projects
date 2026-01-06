-- Added: Register B support (expanded mOPs, updated databus)
-- Fixed: mOPs width from 27 to 29 bits
-- Fixed: databus now includes BIN and BBUS ports

LIBRARY ieee;
USE ieee.std_logic_1164.all;

PACKAGE cpulib IS

    -- ====================================================================
    -- Control Unit Component (Updated for A6)
    -- ====================================================================
    -- CHANGED FOR A6: mOPs expanded from 27 bits to 29 bits
    -- - mOPs[27] = BLOAD (load Register B)
    -- - mOPs[28] = BBUS (Register B on data bus)
    COMPONENT control_unit IS
        PORT (
            ir           : IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
            z            : IN  STD_LOGIC;
            clock        : IN  STD_LOGIC;
            reset        : IN  STD_LOGIC;
            mOPs         : OUT STD_LOGIC_VECTOR(28 DOWNTO 0)  -- CHANGED: 26 → 28 for A6
        );
    END COMPONENT;

    -- ====================================================================
    -- ALU Signal Generator Component
    -- ====================================================================
    -- No changes from A5 - still generates 7-bit ALU control codes
    COMPONENT alus IS
        PORT (
            rbus, acload, zload, andop : IN STD_LOGIC;
            orop, notop, xorop, aczero : IN STD_LOGIC;
            acinc, plus, minus, drbus : IN STD_LOGIC;
            alus : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
        );
    END COMPONENT;

    -- ====================================================================
    -- Data Bus Multiplexer Component (Updated for A6)
    -- ====================================================================
    -- CHANGED: Added Register B input and control signal
    -- Data sources increased from 6 to 7:
    -- - Assignment 5: PC, DR, TR, R, AC, Memory
    -- - Assignment 6: PC, DR, TR, R, AC, B, Memory (NEW: Register B)
    COMPONENT databus IS
        PORT (
            -- Data inputs from CPU registers
            PCIN   : IN STD_LOGIC_VECTOR(15 DOWNTO 0); -- Program Counter (16-bit)
            DRIN   : IN STD_LOGIC_VECTOR(7 DOWNTO 0);  -- Data Register
            TRIN   : IN STD_LOGIC_VECTOR(7 DOWNTO 0);  -- Temp Register
            RIN    : IN STD_LOGIC_VECTOR(7 DOWNTO 0);  -- General Purpose Register
            ACIN   : IN STD_LOGIC_VECTOR(7 DOWNTO 0);  -- Accumulator
            BIN    : IN STD_LOGIC_VECTOR(7 DOWNTO 0);  -- NEW FOR A6: Register B
            MEMIN  : IN STD_LOGIC_VECTOR(7 DOWNTO 0);  -- Memory output
            
            -- Bus control signals (one-hot encoding, control unit ensures mutex)
            PCBUS  : IN STD_LOGIC;  -- Route PC to bus
            DRBUS  : IN STD_LOGIC;  -- Route DR to bus
            TRBUS  : IN STD_LOGIC;  -- Route TR to bus
            RBUS   : IN STD_LOGIC;  -- Route R to bus
            ACBUS  : IN STD_LOGIC;  -- Route AC to bus
            BBUS   : IN STD_LOGIC;  -- NEW FOR A6: Route B to bus
            MEMBUS : IN STD_LOGIC;  -- Route Memory to bus
            
            -- Internal data bus output
            BUSOUT : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)  -- Selected source (8-bit)
        );
    END COMPONENT;

    -- ====================================================================
    -- Memory Component (Unchanged from A5)
    -- ====================================================================
    -- Single-port RAM: 256x8 (256 bytes, 8-bit data)
    -- Initialized from extRAM_A6.mif file
    COMPONENT ram1
        PORT (
            address : IN STD_LOGIC_VECTOR (7 DOWNTO 0);   -- 8-bit address (256 locations)
            clock   : IN STD_LOGIC  := '1';               -- Clock signal
            data    : IN STD_LOGIC_VECTOR (7 DOWNTO 0);   -- 8-bit write data
            wren    : IN STD_LOGIC;                        -- Write enable
            q       : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)   -- 8-bit read data
        );
    END COMPONENT;

    -- ====================================================================
    -- 16-bit Register Component (Unchanged from A5)
    -- ====================================================================
    -- Used for: Address Register (AR), Program Counter (PC)
    -- Features: Load, Increment, Asynchronous Reset
    COMPONENT reg16 IS
        PORT(
            clk : IN STD_LOGIC;               -- Clock
            rst : IN STD_LOGIC;               -- Asynchronous reset
            ld  : IN STD_LOGIC;               -- Synchronous load
            inc : IN STD_LOGIC;               -- Synchronous increment
            d   : IN STD_LOGIC_VECTOR(15 DOWNTO 0);   -- Data input
            q   : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)   -- Data output
        );
    END COMPONENT;

    -- ====================================================================
    -- 8-bit Register Component (Unchanged from A5)
    -- ====================================================================
    -- Used for: Data Register (DR), Instruction Register (IR), Temp (TR),
    --           General Purpose (R), Accumulator (AC), Register B
    -- Features: Load, Increment, Clear, Asynchronous Reset
    COMPONENT reg8 IS
        PORT(
            clk : IN STD_LOGIC;               -- Clock
            rst : IN STD_LOGIC;               -- Asynchronous reset
            ld  : IN STD_LOGIC;               -- Synchronous load
            inc : IN STD_LOGIC;               -- Synchronous increment
            clr : IN STD_LOGIC;               -- Synchronous clear (zero)
            d   : IN STD_LOGIC_VECTOR(7 DOWNTO 0);    -- Data input
            q   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)    -- Data output
        );
    END COMPONENT;

    -- ====================================================================
    -- 1-bit Register Component (Unchanged from A5)
    -- ====================================================================
    -- Used for: Zero Flag (Z register)
    -- Features: Load, Asynchronous Reset
    COMPONENT reg1 IS
        PORT(
            clk : IN STD_LOGIC;               -- Clock
            rst : IN STD_LOGIC;               -- Asynchronous reset
            ld  : IN STD_LOGIC;               -- Synchronous load
            d   : IN STD_LOGIC;               -- Data input (1-bit)
            q   : OUT STD_LOGIC               -- Data output (1-bit)
        );
    END COMPONENT;

END PACKAGE cpulib;
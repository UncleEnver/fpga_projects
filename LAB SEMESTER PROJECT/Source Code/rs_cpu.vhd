LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE work.cpulib.all;

ENTITY rs_cpu IS
    PORT(
        ARdata, PCdata : BUFFER STD_LOGIC_VECTOR(15 DOWNTO 0);
        DRdata, ACdata : BUFFER STD_LOGIC_VECTOR(7 DOWNTO 0);
        IRdata, TRdata : BUFFER STD_LOGIC_VECTOR(7 DOWNTO 0);
        RRdata         : BUFFER STD_LOGIC_VECTOR(7 DOWNTO 0);
        BRdata         : BUFFER STD_LOGIC_VECTOR(7 DOWNTO 0);  -- NEW: Register B
        ZRdata         : BUFFER STD_LOGIC;
        clock, reset   : IN STD_LOGIC;
        MOP            : BUFFER STD_LOGIC_VECTOR(28 DOWNTO 0);  -- EXPANDED: 27 → 29 bits
        addressBus     : BUFFER STD_LOGIC_VECTOR(15 DOWNTO 0);
        cpu_data_bus   : BUFFER STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END rs_cpu;

ARCHITECTURE arc OF rs_cpu IS

    -- Internal signals
    SIGNAL internal_bus_8bit : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL internal_bus_16bit : STD_LOGIC_VECTOR(15 DOWNTO 0); -- Extended for AR/PC
    SIGNAL mem_to_bus   : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL alu_out      : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL alu_ctrl     : STD_LOGIC_VECTOR(6 DOWNTO 0);
    SIGNAL z_calc       : STD_LOGIC; -- Calculated Z value
    SIGNAL ac_input     : STD_LOGIC_VECTOR(7 DOWNTO 0); -- AC Input Multiplexer
    SIGNAL alu_active   : STD_LOGIC;

BEGIN

    -- ===================================================================
    -- 1. Control Unit
    -- ===================================================================
    CU_INST: control_unit PORT MAP(
        ir    => IRdata,
        z     => ZRdata,
        clock => clock,
        reset => reset,
        mOPs  => MOP
    );

    -- ===================================================================
    -- 2. Data Bus (8-bit) - Routes data between components
    -- ===================================================================
    BUS_INST: databus PORT MAP(
        PCIN   => PCdata,
        DRIN   => DRdata,
        TRIN   => TRdata,
        RIN    => RRdata,
        ACIN   => ACdata,
        BIN    => BRdata,           -- NEW: B register input
        MEMIN  => mem_to_bus,
        PCBUS  => MOP(14),  -- PC on bus
        DRBUS  => MOP(15),  -- DR on bus
        TRBUS  => MOP(16),  -- TR on bus
        RBUS   => MOP(17),  -- R on bus
        ACBUS  => MOP(18),  -- AC on bus
        BBUS   => MOP(28),  -- NEW: B on bus control
        MEMBUS => MOP(12),  -- Memory to bus
        BUSOUT => internal_bus_8bit
    );
    
    -- Zero-extend 8-bit bus for 16-bit registers (AR, PC)
    internal_bus_16bit <= "00000000" & internal_bus_8bit;

    -- ===================================================================
    -- 3. Memory Interface
    -- ===================================================================
    MEMORY_UNIT: ram1 PORT MAP(
        address => ARdata(7 DOWNTO 0), -- Using lower 8 bits of AR for 256-byte RAM
        clock   => clock,
        data    => internal_bus_8bit,
        wren    => MOP(11),  -- Write enable from control unit
        q       => mem_to_bus
    );

    -- ===================================================================
    -- 4. Register File (All CPU Registers)
    -- ===================================================================
    
    -- AR (Address Register - 16-bit): Holds memory addresses
    AR_REG: reg16 PORT MAP(
        clk => clock, rst => reset, 
        ld => MOP(0),           -- ARLOAD
        inc => MOP(1),          -- ARINC
        d => internal_bus_16bit, 
        q => ARdata
    );

    -- PC (Program Counter - 16-bit): Holds next instruction address
    PC_REG: reg16 PORT MAP(
        clk => clock, rst => reset, 
        ld => MOP(2),           -- PCLOAD
        inc => MOP(3),          -- PCINC
        d => internal_bus_16bit, 
        q => PCdata
    );

    -- DR (Data Register - 8-bit): Temporary storage from memory
    DR_REG: reg8 PORT MAP(
        clk => clock, rst => reset, 
        ld => MOP(4),   -- DRLOAD
        inc => '0',     -- Not used
        clr => '0',     -- Not used
        d => internal_bus_8bit, 
        q => DRdata
    );

    -- IR (Instruction Register - 8-bit): Holds current instruction
    IR_REG: reg8 PORT MAP(
        clk => clock, rst => reset, 
        ld => MOP(6),   -- IRLOAD
        inc => '0', 
        clr => '0',
        d => internal_bus_8bit, 
        q => IRdata
    );
    
    -- TR (Temp Register - 8-bit): Temporary storage
    TR_REG: reg8 PORT MAP(
        clk => clock, rst => reset, 
        ld => MOP(5),   -- TRLOAD
        inc => '0', 
        clr => '0',
        d => internal_bus_8bit, 
        q => TRdata
    );
    
    -- R (General Purpose Register - 8-bit)
    R_REG: reg8 PORT MAP(
        clk => clock, rst => reset, 
        ld => MOP(7),   -- RLOAD
        inc => '0', 
        clr => '0',
        d => internal_bus_8bit, 
        q => RRdata
    );

    -- ===================================================================
    -- NEW: B Register (8-bit) - Dedicated for ADDB/SUBB operations
    -- ===================================================================
    -- B is loaded via MOP(27) = BLOAD signal from control unit
    -- B is used as second operand in ALU for ADDB/SUBB instructions
    B_REG: reg8 PORT MAP(
        clk => clock, rst => reset, 
        ld => MOP(27),  -- BLOAD (from control unit)
        inc => '0',     -- Not used
        clr => '0',     -- Not used
        d => internal_bus_8bit, 
        q => BRdata
    );

    -- ===================================================================
    -- 5. Accumulator (AC) Register with ALU Multiplexer
    -- ===================================================================
    
    -- ALU is active when any arithmetic/logic operation is active
    alu_active <= MOP(25) OR MOP(26) OR MOP(19) OR MOP(20) OR 
                  MOP(21) OR MOP(22) OR MOP(23) OR MOP(24);

    -- AC input multiplexer: Routes either ALU output or bus data to AC
    -- When ALU is active: Use ALU output (result of arithmetic/logic)
    -- When ALU is inactive: Use data bus (for load operations)
    ac_input <= alu_out WHEN alu_active = '1' ELSE internal_bus_8bit;

    -- AC Register
    AC_REG: reg8 PORT MAP(
        clk => clock, rst => reset, 
        ld => MOP(8),     -- ACLOAD
        inc => MOP(23),   -- ACINC (for increment operations)
        clr => MOP(24),   -- ACZERO (for clear operations)
        d => ac_input,    -- Multiplexed input (ALU or bus)
        q => ACdata
    );

    -- ===================================================================
    -- 6. ALU Control Unit - Generates ALU operation codes
    -- ===================================================================
    ALU_CTRL_UNIT: alus PORT MAP(
        rbus => MOP(17),   -- R on bus
        drbus => MOP(15),  -- DR on bus
        acload => MOP(8),  -- AC load
        zload => MOP(9),   -- Z flag load
        andop => MOP(19),  -- AND operation
        orop => MOP(20),   -- OR operation
        notop => MOP(22),  -- NOT operation
        xorop => MOP(21),  -- XOR operation
        aczero => MOP(24), -- AC zero (clear)
        acinc => MOP(23),  -- AC increment
        plus => MOP(25),   -- ADD operation (includes ADDB)
        minus => MOP(26),  -- SUBTRACT operation (includes SUBB)
        alus => alu_ctrl   -- Output: 7-bit ALU control code
    );

    -- ===================================================================
    -- 7. ALU Logic (Combinational) - Implements actual operations
    -- ===================================================================
    PROCESS(ACdata, RRdata, BRdata, DRdata, alu_ctrl)
    BEGIN
        CASE alu_ctrl IS
            -- Logical Operations
            WHEN "1000000" => alu_out <= ACdata AND DRdata;    -- AND
            WHEN "1100000" => alu_out <= ACdata OR DRdata;     -- OR  
            WHEN "1110000" => alu_out <= NOT ACdata;           -- NOT
            WHEN "1010000" => alu_out <= ACdata XOR DRdata;    -- XOR
            
            -- Arithmetic Operations
            WHEN "0000101" => alu_out <= ACdata + DRdata;      -- ADD
            WHEN "0001011" => alu_out <= ACdata - DRdata;      -- SUB
            
            -- NEW: ADDB and SUBB (Use Register B as second operand)
            WHEN "0001100" => alu_out <= ACdata + BRdata;      -- ADDB: AC ← AC + B
            WHEN "0001101" => alu_out <= ACdata - BRdata;      -- SUBB: AC ← AC - B
            
            -- Move Operations
            WHEN "0000100" => alu_out <= RRdata;               -- MOVR (Move R to AC)
            
            -- Default: Hold AC value
            WHEN OTHERS    => alu_out <= ACdata;
        END CASE;
    END PROCESS;

    -- ===================================================================
    -- 8. Zero Flag (Z) Register - Reflects if result is zero
    -- ===================================================================
    -- Calculate Z value: 1 if ALU result is zero, 0 otherwise
    -- Only update during actual arithmetic/logic operations
    z_calc <= '1' WHEN (alu_active = '1' AND alu_out = "00000000") ELSE '0';

    -- Z Flag Register
    Z_REG: reg1 PORT MAP(
        clk => clock, rst => reset,
        ld => MOP(9),  -- ZLOAD (from control unit)
        d => z_calc,
        q => ZRdata
    );

    -- ===================================================================
    -- 9. External Bus Connections (for testbench/external observation)
    -- ===================================================================
    addressBus   <= ARdata;          -- AR contents on external address bus
    cpu_data_bus <= internal_bus_8bit; -- Data bus contents visible externally

END arc;

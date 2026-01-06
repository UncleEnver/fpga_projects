library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.hardwiredlib.all;

entity control_unit is
    port(
        ir           : in  std_logic_vector(7 downto 0);
        z            : in  std_logic;
        clock        : in  std_logic;
        reset        : in  std_logic;
        mOPs         : out std_logic_vector(28 downto 0)
    );
end control_unit;

architecture rtl of control_unit is
    
    -- Instruction decoder output
    signal inst_decode : std_logic_vector(15 downto 0);
    signal INOP, ILDAC, ISTAC, IMVAC, IMOVR, IJUMP, IJMPZ, IJPNZ : std_logic;
    signal IADD, ISUB, IINAC, ICLAC, IAND, IOR, IXOR, INOT : std_logic;
    signal IADDB, ISUBB, IMOVB : std_logic;  -- FIXED: Added IMOVB
    
    -- State decoder output
    signal state_decode : std_logic_vector(7 downto 0);
    signal T0, T1, T2, T3, T4, T5, T6, T7 : std_logic;
    
    -- Counter signals
    signal counter_out : std_logic_vector(2 downto 0);
    signal counter_inc : std_logic;
    signal counter_clr : std_logic;
    
    -- FSM state signals
    signal FETCH1, FETCH2, FETCH3 : std_logic;
    signal NOP1 : std_logic;
    signal LDAC1, LDAC2, LDAC3, LDAC4, LDAC5 : std_logic;
    signal STAC1, STAC2, STAC3, STAC4, STAC5 : std_logic;
    signal MVAC1, MOVR1, MOVR2 : std_logic;
    signal MOVB1, MOVB2 : std_logic;  -- Added MOVB states
    signal JUMP1, JUMP2, JUMP3 : std_logic;
    signal JMPZY1, JMPZY2, JMPZY3 : std_logic;
    signal JMPZN1, JMPZN2 : std_logic;
    signal JPNZY1, JPNZY2, JPNZY3 : std_logic;
    signal JPNZN1, JPNZN2 : std_logic;
    signal ADD1, SUB1, INAC1, CLAC1 : std_logic;
    signal AND1, OR1, XOR1, NOT1 : std_logic;
    signal ADDB1, SUBB1 : std_logic;
    
    -- 29 Individual micro-operations
    signal ARLOAD, ARINC, PCLOAD, PCINC, DRLOAD, TRLOAD, IRLOAD, RLOAD : std_logic;
    signal ACLOAD, ZLOAD, RD, WR, MEMBUS, BUSMEM : std_logic;
    signal PCBUS, DRBUS, TRBUS, RBUS, ACBUS : std_logic;
    signal ANDOP, OROP, XOROP, NOTOP : std_logic;
    signal ACINC, ACZERO, PLUS, MINUS : std_logic;
    signal BLOAD, BBUS : std_logic;
    
    signal Z_not : std_logic;

begin

    -- Decoder instantiations
    inst_decoder : decoder_generic
        generic map(INPUT_WIDTH => 4, OUTPUT_WIDTH => 16)
        port map(din => ir(3 downto 0), dout => inst_decode);
    
    state_decoder : decoder_generic
        generic map(INPUT_WIDTH => 3, OUTPUT_WIDTH => 8)
        port map(din => counter_out, dout => state_decode);
    
    counter : counter_3bit
        port map(clk => clock, rst => counter_clr, inc => counter_inc, count => counter_out);

    -- ===============================================================
    -- Instruction Decode Signal Assignments
    -- ===============================================================
    
    -- Standard 16 instructions decoded from IR[3:0]
    INOP  <= inst_decode(0);
    ILDAC <= inst_decode(1);
    ISTAC <= inst_decode(2);
    IMVAC <= inst_decode(3);
    IMOVR <= inst_decode(4);
    IJUMP <= inst_decode(5);
    IJMPZ <= inst_decode(6);
    IJPNZ <= inst_decode(7);
    IADD  <= inst_decode(8);
    ISUB  <= inst_decode(9);
    IINAC <= inst_decode(10);
    ICLAC <= inst_decode(11);
    IAND  <= inst_decode(12);
    IOR   <= inst_decode(13);
    IXOR  <= inst_decode(14);
    INOT  <= inst_decode(15);
    
    -- FIXED: Explicit decoders for special opcodes outside 4-bit range
    IADDB <= '1' when ir = x"18" else '0';  -- ADDB opcode
    ISUBB <= '1' when ir = x"19" else '0';  -- SUBB opcode
    IMOVB <= '1' when ir = x"04" else '0';  -- MOVB opcode
    
    -- State signals from 3-bit counter decoder
    T0 <= state_decode(0);
    T1 <= state_decode(1);
    T2 <= state_decode(2);
    T3 <= state_decode(3);
    T4 <= state_decode(4);
    T5 <= state_decode(5);
    T6 <= state_decode(6);
    T7 <= state_decode(7);
    
    Z_not <= not z;

    -- ===============================================================
    -- FSM State Generation (Instruction + Timing)
    -- ===============================================================
    
    FETCH1 <= T0;
    FETCH2 <= T1;
    FETCH3 <= T2;
    
    NOP1 <= INOP and T3;
    
    LDAC1 <= ILDAC and T3;
    LDAC2 <= ILDAC and T4;
    LDAC3 <= ILDAC and T5;
    LDAC4 <= ILDAC and T6;
    LDAC5 <= ILDAC and T7;
    
    STAC1 <= ISTAC and T3;
    STAC2 <= ISTAC and T4;
    STAC3 <= ISTAC and T5;
    STAC4 <= ISTAC and T6;
    STAC5 <= ISTAC and T7;
    
    MVAC1 <= IMVAC and T3;
    
    MOVR1 <= IMOVR and T3;
    MOVR2 <= IMOVR and T4;
    
    -- Added MOVB (Move to B) instruction sequence
    MOVB1 <= IMOVB and T3;
    MOVB2 <= IMOVB and T4;
    
    JUMP1 <= IJUMP and T3;
    JUMP2 <= IJUMP and T4;
    JUMP3 <= IJUMP and T5;
    
    JMPZY1 <= IJMPZ and z and T3;
    JMPZY2 <= IJMPZ and z and T4;
    JMPZY3 <= IJMPZ and z and T5;
    JMPZN1 <= IJMPZ and Z_not and T3;
    JMPZN2 <= IJMPZ and Z_not and T4;
    
    JPNZY1 <= IJPNZ and Z_not and T3;
    JPNZY2 <= IJPNZ and Z_not and T4;
    JPNZY3 <= IJPNZ and Z_not and T5;
    JPNZN1 <= IJPNZ and z and T3;
    JPNZN2 <= IJPNZ and z and T4;
    
    ADD1  <= IADD and T3;
    SUB1  <= ISUB and T3;
    INAC1 <= IINAC and T3;
    CLAC1 <= ICLAC and T3;
    AND1  <= IAND and T3;
    OR1   <= IOR and T3;
    XOR1  <= IXOR and T3;
    NOT1  <= INOT and T3;
    
    ADDB1 <= IADDB and T3;
    SUBB1 <= ISUBB and T3;

    -- ===============================================================
    -- Counter Control Signals
    -- ===============================================================
    
    counter_clr <= reset or T7;
    counter_inc <= '1';

    -- ===============================================================
    -- Micro-Operation Logic
    -- ===============================================================
    
    ARLOAD <= FETCH1 OR FETCH3 OR LDAC1 OR LDAC2 OR STAC1 OR STAC2 OR MOVR1;
    ARINC  <= '0';
    
    PCLOAD <= JUMP3 OR JMPZY3 OR JPNZY3;
    PCINC  <= FETCH2 OR JMPZN2 OR JPNZN2 OR LDAC2 OR LDAC4 OR STAC2 OR STAC4 OR MOVR2 OR MOVB2;
    
    DRLOAD <= FETCH2 OR LDAC2 OR ADD1 OR SUB1 OR AND1 OR OR1 OR XOR1 OR ADDB1 OR SUBB1 OR MOVB1;
    
    TRLOAD <= '0';
    
    IRLOAD <= FETCH2;
    
    RLOAD  <= MOVR2;
    
    ACLOAD <= LDAC3 OR ADD1 OR SUB1 OR AND1 OR OR1 OR XOR1 OR NOT1 OR MVAC1 OR ADDB1 OR SUBB1;
    
    ZLOAD  <= ADD1 OR SUB1 OR AND1 OR OR1 OR XOR1 OR NOT1 OR INAC1 OR CLAC1 OR ADDB1 OR SUBB1;
    
    RD     <= FETCH2 OR LDAC2 OR LDAC3 OR STAC2 OR MOVR2 OR MOVB1 OR ADDB1 OR SUBB1;
    WR     <= STAC3;
    
    PCBUS  <= FETCH1 OR FETCH3 OR LDAC1 OR STAC1 OR MOVR1;
    DRBUS  <= '0';
    TRBUS  <= '0';
    RBUS   <= MVAC1;
    ACBUS  <= STAC3;
    -- Added MOVB1 and MOVB2 to MEMBUS
    MEMBUS <= FETCH2 OR LDAC2 OR LDAC3 OR STAC2 OR MOVR2 OR MOVB1 OR MOVB2 OR ADDB1 OR SUBB1;
    BUSMEM <= STAC3;
    
    ANDOP  <= AND1;
    OROP   <= OR1;
    XOROP  <= XOR1;
    NOTOP  <= NOT1;
    ACINC  <= INAC1;
    ACZERO <= CLAC1;
    
    PLUS   <= ADD1 OR ADDB1;
    MINUS  <= SUB1 OR SUBB1;

    -- ===============================================================
    -- B Register Control Signals
    -- ===============================================================
    
    -- Load B at T4 of MOVB instruction (after operand is available)
    -- This ensures B is loaded BEFORE ADDB/SUBB execute
    BLOAD <= MOVB2;  -- Load B during second cycle of MOVB
    
    BBUS  <= '0';

    -- ===============================================================
    -- Final Output: mOPs Vector (29 bits)
    -- ===============================================================
    
    mOPs(0)  <= ARLOAD;
    mOPs(1)  <= ARINC;
    mOPs(2)  <= PCLOAD;
    mOPs(3)  <= PCINC;
    mOPs(4)  <= DRLOAD;
    mOPs(5)  <= TRLOAD;
    mOPs(6)  <= IRLOAD;
    mOPs(7)  <= RLOAD;
    mOPs(8)  <= ACLOAD;
    mOPs(9)  <= ZLOAD;
    mOPs(10) <= RD;
    mOPs(11) <= WR;
    mOPs(12) <= MEMBUS;
    mOPs(13) <= BUSMEM;
    mOPs(14) <= PCBUS;
    mOPs(15) <= DRBUS;
    mOPs(16) <= TRBUS;
    mOPs(17) <= RBUS;
    mOPs(18) <= ACBUS;
    mOPs(19) <= ANDOP;
    mOPs(20) <= OROP;
    mOPs(21) <= XOROP;
    mOPs(22) <= NOTOP;
    mOPs(23) <= ACINC;
    mOPs(24) <= ACZERO;
    mOPs(25) <= PLUS;
    mOPs(26) <= MINUS;
    mOPs(27) <= BLOAD;
    mOPs(28) <= BBUS;

end rtl;

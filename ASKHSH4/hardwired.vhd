library ieee;
use ieee.std_logic_1164.all ;
use ieee.std_logic_unsigned.all ; -- Χρησιμοποιείται για το std_logic_vector
library lpm;
use lpm.lpm_components.all ;
use work.hardwiredlib.all ; -- Εισαγωγή των Components

entity hardwired is
port ( ir            	  :  in  std_logic_vector(3  downto  0);
       clock, reset  :  in  std_logic ;
       z             	  :  in  std_logic ; -- Καταχωρητής σημαίας (Ζ)
       mOPs             :  out  std_logic_vector(26  downto  0)); -- Σήματα Ελέγχου
end hardwired;

architecture arc of hardwired is

    -- Σήματα για τη σύνδεση των υπομονάδων
    SIGNAL I_signals : STD_LOGIC_VECTOR(15 DOWNTO 0); -- Έξοδος decoder4to16 (I_NOP, I_LDAC, I_STAC, ...)
    SIGNAL T_count   : STD_LOGIC_VECTOR(2 DOWNTO 0);  -- Έξοδος counter3bit (Τιμή 000 έως 111)
    SIGNAL T_signals : STD_LOGIC_VECTOR(7 DOWNTO 0);  -- Έξοδος decoder3to8 (T0, T1, ..., T7)

    -- Σήματα Ελέγχου για τον Counter
    SIGNAL counter_inc : STD_LOGIC; -- Σήμα αύξησης (inc)
    SIGNAL counter_clr : STD_LOGIC; -- Σήμα μηδενισμού (clr)

    -- Δήλωση των μεμονωμένων σημάτων εντολών για ευκολότερη χρήση
    -- (Αντιστοίχιση των bits του I_signals σύμφωνα με το ρεπερτόριο εντολών)
    -- ΥΠΟΘΕΣΗ: Η αντιστοίχιση έγινε με αύξοντα Opcode:
    -- 0=NOP, 1=LDAC, 2=STAC, 3=MVAC, 4=MOVR, 5=JUMP, 6=JMPZ, 7=JPNZ, 8=ADD, 9=SUB, A=INAC, B=CLAC, C=AND, D=OR, E=XOR, F=NOT
    SIGNAL I_NOP, I_LDAC, I_STAC, I_MVAC, I_MOVR, I_JUMP, I_JMPZ, I_JPNZ, I_ADD, I_SUB, I_INAC, I_CLAC, I_AND, I_OR, I_XOR, I_NOT : STD_LOGIC;

    -- Δήλωση των χρονικών σημάτων T0 έως T7
    SIGNAL T0, T1, T2, T3, T4, T5, T6, T7 : STD_LOGIC;

    -- Σήματα Επιμέρους Καταστάσεων (Παραγωγή Καταστάσεων)
    -- FETCH
    SIGNAL FETCH1, FETCH2, FETCH3 : STD_LOGIC;
    -- NOP
    SIGNAL NOP1 : STD_LOGIC;
    -- LDAC
    SIGNAL LDAC1, LDAC2, LDAC3, LDAC4, LDAC5 : STD_LOGIC;
    -- STAC
    SIGNAL STAC1, STAC2, STAC3, STAC4, STAC5 : STD_LOGIC;
    -- MVAC, MOVR, JUMP
    SIGNAL MVAC1, MOVR1 : STD_LOGIC;
    SIGNAL JUMP1, JUMP2, JUMP3 : STD_LOGIC;
    -- JMPZ
    SIGNAL JMPZY1, JMPZY2, JMPZY3 : STD_LOGIC;
    SIGNAL JMPZN1, JMPZN2 : STD_LOGIC;
    -- JPNZ
    SIGNAL JPNZY1, JPNZY2, JPNZY3 : STD_LOGIC;
    SIGNAL JPNZN1, JPNZN2 : STD_LOGIC;
    -- ALU/Logical
    SIGNAL ADD1, SUB1, INAC1, CLAC1, AND1, OR1, XOR1, NOT1 : STD_LOGIC;

    -- Δήλωση των σημάτων ελέγχου (mOPs) - Αντιστοίχιση με Πίνακα 2.
    -- ΥΠΟΘΕΣΗ: Η σειρά των σημάτων στο mOPs(26 downto 0) ακολουθεί τον Πίνακα 2 από πάνω προς τα κάτω
    -- (26=ARLOAD, 25=ARINC, ..., 0=MINUS)
    SIGNAL ARLOAD, ARINC, PCLOAD, PCINC, DRLOAD, TRLOAD, IRLOAD, RLOAD, ACLOAD, ZLOAD, READ_s, WRITE_s,
           MEMBUS, BUSMEM, PCBUS, DRBUS, TRBUS, RBUS, ACBUS, ANDOP, OROP, XOROP, NOTOP, ACINC, ACZERO, PLUS, MINUS : STD_LOGIC;

BEGIN
    -- 1. Συνδεσμολογία Components
    -- 1.1. Αποκωδικοποιητής Εντολών (4 σε 16)
    U_Instruction_Decoder: decoder4to16 PORT MAP (
        Din => ir,
        Dout => I_signals
    );

    -- 1.2. Απαριθμητής Καταστάσεων (3-bit)
    U_State_Counter: counter3bit PORT MAP (
        clock => clock,
        rst   => reset OR counter_clr, -- Μηδενισμός από reset Ή σήμα counter_clr
        inc   => counter_inc,          -- Αύξηση από σήμα counter_inc
        count => T_count
    );

    -- 1.3. Αποκωδικοποιητής Καταστάσεων (3 σε 8)
    U_State_Decoder: decoder3to8 PORT MAP (
        Din => T_count,
        Dout => T_signals
    );

    -- 2. Αντιστοίχιση Σημάτων Εντολών και Χρόνου
    -- Από το I_signals(15 downto 0)
    I_NOT  <= I_signals(15);
    I_XOR  <= I_signals(14);
    I_OR   <= I_signals(13);
    I_AND  <= I_signals(12);
    I_CLAC <= I_signals(11);
    I_INAC <= I_signals(10);
    I_SUB  <= I_signals(9);
    I_ADD  <= I_signals(8);
    I_JPNZ <= I_signals(7);
    I_JMPZ <= I_signals(6);
    I_JUMP <= I_signals(5);
    I_MOVR <= I_signals(4);
    I_MVAC <= I_signals(3);
    I_STAC <= I_signals(2);
    I_LDAC <= I_signals(1);
    I_NOP  <= I_signals(0);

    -- Από το T_signals(7 downto 0)
    T7 <= T_signals(7);
    T6 <= T_signals(6);
    T5 <= T_signals(5);
    T4 <= T_signals(4);
    T3 <= T_signals(3);
    T2 <= T_signals(2);
    T1 <= T_signals(1);
    T0 <= T_signals(0);

    -- 3. Παραγωγή Επιμέρους Καταστάσεων (Πίνακας 1)
    -- FETCH
    FETCH1 <= T0;
    FETCH2 <= T1;
    FETCH3 <= T2;

    -- NOP
    NOP1 <= I_NOP AND T3;

    -- LDAC
    LDAC1 <= I_LDAC AND T3;
    LDAC2 <= I_LDAC AND T4;
    LDAC3 <= I_LDAC AND T5;
    LDAC4 <= I_LDAC AND T6;
    LDAC5 <= I_LDAC AND T7;

    -- STAC
    STAC1 <= I_STAC AND T3;
    STAC2 <= I_STAC AND T4;
    STAC3 <= I_STAC AND T5;
    STAC4 <= I_STAC AND T6;
    STAC5 <= I_STAC AND T7;

    -- MVAC / MOVR
    MVAC1 <= I_MVAC AND T3;
    MOVR1 <= I_MOVR AND T3;

    -- JUMP
    JUMP1 <= I_JUMP AND T3;
    JUMP2 <= I_JUMP AND T4;
    JUMP3 <= I_JUMP AND T5;

    -- JMPZ
    JMPZY1 <= I_JMPZ AND z AND T3;
    JMPZY2 <= I_JMPZ AND z AND T4;
    JMPZY3 <= I_JMPZ AND z AND T5;
    JMPZN1 <= I_JMPZ AND (NOT z) AND T3;
    JMPZN2 <= I_JMPZ AND (NOT z) AND T4;

    -- JPNZ
    JPNZY1 <= I_JPNZ AND (NOT z) AND T3;
    JPNZY2 <= I_JPNZ AND (NOT z) AND T4;
    JPNZY3 <= I_JPNZ AND (NOT z) AND T5;
    JPNZN1 <= I_JPNZ AND z AND T3;
    JPNZN2 <= I_JPNZ AND z AND T4;

    -- ALU/Logical
    ADD1  <= I_ADD AND T3;
    SUB1  <= I_SUB AND T3;
    INAC1 <= I_INAC AND T3;
    CLAC1 <= I_CLAC AND T3;
    AND1  <= I_AND AND T3;
    OR1   <= I_OR AND T3;
    XOR1  <= I_XOR AND T3;
    NOT1  <= I_NOT AND T3;


    -- 4. Παραγωγή Σημάτων Ελέγχου του Απαριθμητή (inc/clr)
    -- Σήμα counter_clr: OR όλων των ΤΕΛΕΥΤΑΙΩΝ καταστάσεων [cite: 32]
    counter_clr <= LDAC5 OR STAC5 OR JUMP3 OR JMPZY3 OR JMPZN2 OR JPNZY3 OR JPNZN2 OR NOP1 OR MVAC1 OR MOVR1 OR ADD1 OR SUB1 OR INAC1 OR CLAC1 OR AND1 OR OR1 OR XOR1 OR NOT1;

    -- Σήμα counter_inc: OR ΟΛΩΝ των καταστάσεων εκτός της τελευταίας [cite: 33]
    counter_inc <= FETCH1 OR FETCH2 OR LDAC1 OR LDAC2 OR LDAC3 OR LDAC4 OR STAC1 OR STAC2 OR STAC3 OR STAC4 OR JUMP1 OR JUMP2 OR JMPZY1 OR JMPZY2 OR JMPZN1 OR JPNZY1 OR JPNZY2 OR JPNZN1;


    -- 5. Παραγωγή Σημάτων Ελέγχου ΚΜΕ (mOPs) (Πίνακας 2)
    -- Η συνδυαστική λογική (combinational logic) για την παραγωγή των σημάτων ελέγχου. [cite: 34]
    ARLOAD <= FETCH1 OR FETCH3 OR LDAC3 OR STAC3;
    ARINC <= LDAC1 OR STAC1 OR JMPZY1 OR JPNZY1;
    PCLOAD <= JUMP3 OR JMPZY3 OR JPNZY3;
    PCINC <= FETCH2 OR LDAC1 OR LDAC2 OR STAC1 OR STAC2 OR JMPZN1 OR JMPZN2 OR JPNZN1 OR JPNZN2;
    DRLOAD <= FETCH2 OR LDAC1 OR LDAC2 OR LDAC4 OR STAC1 OR STAC2 OR STAC4 OR JUMP1 OR JUMP2 OR JMPZY1 OR JMPZY2 OR JPNZY1 OR JPNZY2;
    TRLOAD <= LDAC2 OR STAC2 OR JUMP2 OR JMPZY2 OR JPNZY2;
    IRLOAD <= FETCH3;
    RLOAD <= MVAC1;
    ACLOAD <= LDAC5 OR MOVR1 OR ADD1 OR SUB1 OR INAC1 OR CLAC1 OR AND1 OR OR1 OR XOR1 OR NOT1;
    ZLOAD <= ACLOAD; -- Ίδια συνθήκη με ACLOAD [cite: 36]
    READ_s <= FETCH2 OR LDAC1 OR LDAC2 OR LDAC4 OR STAC1 OR STAC2 OR JUMP1 OR JUMP2 OR JMPZY1 OR JMPZY2 OR JPNZY1 OR JPNZY2;
    WRITE_s <= STAC5;
    MEMBUS <= READ_s; -- Ίδια συνθήκη με READ
    BUSMEM <= STAC5;
    PCBUS <= FETCH1 OR FETCH3;
    DRBUS <= LDAC2 OR LDAC3 OR LDAC5 OR STAC2 OR STAC3 OR STAC5 OR JUMP2 OR JUMP3 OR JMPZY2 OR JMPZY3 OR JPNZY2 OR JPNZY3;
    TRBUS <= LDAC3 OR STAC3 OR JUMP3 OR JMPZY3 OR JPNZY3;
    RBUS <= MOVR1 OR ADD1 OR SUB1 OR AND1 OR OR1 OR XOR1;
    ACBUS <= STAC4 OR MVAC1;
    ANDOP <= AND1;
    OROP <= OR1;
    XOROP <= XOR1;
    NOTOP <= NOT1;
    ACINC <= INAC1;
    ACZERO <= CLAC1;
    PLUS <= ADD1;
    MINUS <= SUB1;

    -- 6. Αντιστοίχιση των Επιμέρους Σημάτων στην Έξοδο mOPs
    -- Η σειρά εξόδου mOPs(26 downto 0) πρέπει να είναι:
    -- ARLOAD, ARINC, PCLOAD, PCINC, DRLOAD, TRLOAD, IRLOAD, RLOAD, ACLOAD, ZLOAD, READ, WRITE, MEMBUS, BUSMEM, PCBUS, DRBUS, TRBUS, RBUS, ACBUS, ANDOP, OROP, XOROP, NOTOP, ACINC, ACZERO, PLUS, MINUS
    mOPs(26) <= ARLOAD;
    mOPs(25) <= ARINC;
    mOPs(24) <= PCLOAD;
    mOPs(23) <= PCINC;
    mOPs(22) <= DRLOAD;
    mOPs(21) <= TRLOAD;
    mOPs(20) <= IRLOAD;
    mOPs(19) <= RLOAD;
    mOPs(18) <= ACLOAD;
    mOPs(17) <= ZLOAD;
    mOPs(16) <= READ_s;
    mOPs(15) <= WRITE_s;
    mOPs(14) <= MEMBUS;
    mOPs(13) <= BUSMEM;
    mOPs(12) <= PCBUS;
    mOPs(11) <= DRBUS;
    mOPs(10) <= TRBUS;
    mOPs(9) <= RBUS;
    mOPs(8) <= ACBUS;
    mOPs(7) <= ANDOP;
    mOPs(6) <= OROP;
    mOPs(5) <= XOROP;
    mOPs(4) <= NOTOP;
    mOPs(3) <= ACINC;
    mOPs(2) <= ACZERO;
    mOPs(1) <= PLUS;
    mOPs(0) <= MINUS;

end arc;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity VGA_Maze_Square is
    Port (
        clk      : in  STD_LOGIC;  
        reset    : in  STD_LOGIC;  
        btn_up   : in  STD_LOGIC;  
        btn_down : in  STD_LOGIC;  
		  Leds     : out std_logic_vector(4 downto 0);
        btn_left : in  STD_LOGIC;  
        btn_right: in  STD_LOGIC;  
        hsync    : out STD_LOGIC;  
        vsync    : out STD_LOGIC;  
		  SW       : in  STD_LOGIC_VECTOR (7 downto 0); 
        red      : out STD_LOGIC_VECTOR (1 downto 0); 
        green    : out STD_LOGIC_VECTOR (1 downto 0); 
		  outseg   : out bit_vector(3 downto 0);
		  sevensegments  : out bit_vector(7 downto 0);
        blue     : out STD_LOGIC_VECTOR (1 downto 0)  
    );
end VGA_Maze_Square;

architecture Behavioral of VGA_Maze_Square is

    constant H_RES       : integer := 640;  
    constant V_RES       : integer := 480;  
    constant H_FP        : integer := 16;   -- Front porch 
    constant H_SYNC_PULSE: integer := 96;   
    constant H_BP        : integer := 48;   -- Back porch 
    constant V_FP        : integer := 10;   -- Front porch 
    constant V_SYNC_PULSE: integer := 2;    
    constant V_BP        : integer := 33;   -- Back porch 

    constant H_TOTAL : integer := H_RES + H_FP + H_SYNC_PULSE + H_BP;
    constant V_TOTAL : integer := V_RES + V_FP + V_SYNC_PULSE + V_BP;

    signal h_count : integer range 0 to H_TOTAL-1 := 0;
    signal v_count : integer range 0 to V_TOTAL-1 := 0;

    signal active_video : STD_LOGIC := '0';
    signal pixel_x : integer range 0 to H_RES-1 := 0;
    signal pixel_y : integer range 0 to V_RES-1 := 0;

	 SIGNAL health : integer range 0 to 5 := 5;
    signal lose   : boolean := false;
	 signal win    : boolean := false;
	 
	 
	  --seven_segment...
	 signal seg0: bit_vector(7 downto 0):=x"c0";
	 signal seg1: bit_vector(7 downto 0):=x"c0";
	 signal seg2: bit_vector(7 downto 0):=x"c0";
    signal seg3: bit_vector(7 downto 0):=x"c0";
    signal seg_selectors : BIT_VECTOR(3 downto 0) := "1110" ;
    signal output: bit_vector(7 downto 0):=x"c0";
  
    signal input :Integer range 0 to 100 :=0;
    signal timer_game : Integer range 0 to 100 :=0;
    signal end_game : bit :='0';


    -- Maze parameters
    constant MazeWidth : integer := 32;
    constant MazeHeight : integer := 24;
    constant CellWidth : integer := 20;
    constant CellHeight : integer := 20;

    type MazeArray is array (0 to MazeHeight-1, 0 to MazeWidth-1) of STD_LOGIC;
    type rand is array(0 to 9) of MazeArray ;
	 signal Maze : MazeArray := (
("11111111111111111111111111111000"),
("10000000000000000000100010001000"),
("10000000000000000000100010001000"),
("10000000000000000000100010001000"),
("10001111111111111000100010001000"),
("10001000000010001000000000001000"),
("10001000000010001000000000001000"),
("10001000000010001000000000001000"),
("10001111100010001111100010001000"),
("10000000000000001000000010001000"),
("10000000000000001000000010001000"),
("10000000000000001000000010001000"),
("11111111100011111111100010001000"),
("10000000000010001000000010001000"),
("10000000000010001000000010001000"),
("10000000000010001000000010001000"),
("11111000100010001111100010001000"),
("10000000100000000000100010001000"),
("10000000100000000000100010001000"),
("10000000100000000000100010001000"),
("11111111111111111111111110001000"),
("00000000000000000000000000000000"),
("00000000000000000000000000000000"),
("00000000000000000000000000000000")
    );
	 --20,[27,26,25]
	 	 
	 signal Mazex : MazeArray := (
	("11111111111111111111111111111000"),
("10000000100000001000000000001000"),
("10000000100000001000000000001000"),
("10000000100000001000000000001000"),
("10001000111110001000111111111000"),
("10001000000000000000000000001000"),
("10001000000000000000000000001000"),
("10001000000000000000000000001000"),
("10001000111111111000111111111000"),
("10001000000000001000000000001000"),
("10001000000000001000000000001000"),
("10001000000000001000000000001000"),
("11111000111111111000111110001000"),
("10000000100000001000000010001000"),
("10000000100000001000000010001000"),
("10000000100000001000000010001000"),
("11111000100010001000111110001000"),
("10000000000010001000000010001000"),
("10000000000010001000000010001000"),
("10000000000010001000000010001000"),
("11111111111111111111111110001000"),
("00000000000000000000000000000000"),
("00000000000000000000000000000000"),
("00000000000000000000000000000000")
  );
 	
   signal Maze1 : MazeArray := (
("11111111111111111111111111111000"),
("10000000000000000000000000001000"),
("10000000000000000000000000001000"),
("10000000000000000000000000001000"),
("11111000111111111111111111111000"),
("10001000000000000000000000001000"),
("10001000000000000000000000001000"),
("10001000000000000000000000001000"),
("10001111111110001000111111111000"),
("10000000100000001000000000001000"),
("10000000100000001000000000001000"),
("10000000100000001000000000001000"),
("11111000111110001111111111111000"),
("10000000000000000000000000001000"),
("10000000000000000000000000001000"),
("10000000000000000000000000001000"),
("11111000100011111000100010001000"),
("10000000100000001000100010001000"),
("10000000100000001000100010001000"),
("10000000100000001000100010001000"),
("11111111111111111111111110001000"),
("00000000000000000000000000000000"),
("00000000000000000000000000000000"),
("00000000000000000000000000000000")
);
  
   signal Maze2 : MazeArray := (

("11111111111111111111111111111000"),
("10001000000000001000000010001000"),
("10001000000000001000000010001000"),
("10001000000000001000000010001000"),
("10001111111110001111100010001000"),
("10000000000000001000100000001000"),
("10000000000000001000100000001000"),
("10000000000000001000100000001000"),
("11111111100011111000100010001000"),
("10000000000000000000000010001000"),
("10000000000000000000000010001000"),
("10000000000000000000000010001000"),
("11111000111110001000100011111000"),
("10001000000010001000100000001000"),
("10001000000010001000100000001000"),
("10001000000010001000100000001000"),
("10001000111111111000111110001000"),
("10000000100000000000100000001000"),
("10000000100000000000100000001000"),
("10000000100000000000100000001000"),
("11111111111111111111111110001000"),
("00000000000000000000000000000000"),
("00000000000000000000000000000000"),
("00000000000000000000000000000000")
	);
	
	
   signal Maze3 : MazeArray := (
("11111111111111111111111111111000"),
("10000000000010000000100000001000"),
("10000000000010000000100000001000"),
("10000000000010000000100000001000"),
("10001000111111111000100011111000"),
("10001000000000000000100000001000"),
("10001000000000000000100000001000"),
("10001000000000000000100000001000"),
("10001111111110001111100011111000"),
("10000000000010000000000000001000"),
("10000000000010000000000000001000"),
("10000000000010000000000000001000"),
("10001111100011111111111110001000"),
("10000000100010000000000000001000"),
("10000000100010000000000000001000"),
("10000000100010000000000000001000"),
("10001000100010001111111111111000"),
("10001000100010000000000000001000"),
("10001000100010000000000000001000"),
("10001000100010000000000000001000"),
("11111111111111111111111110001000"),
("00000000000000000000000000000000"),
("00000000000000000000000000000000"),
("00000000000000000000000000000000")
	);
	
	
   signal Maze4 : MazeArray := (
("11111111111111111111111111111000"),
("10000000100000000000000000001000"),
("10000000100000000000000000001000"),
("10000000100000000000000000001000"),
("10001111111110001111100010001000"),
("10000000000000001000000010001000"),
("10000000000000001000000010001000"),
("10000000000000001000000010001000"),
("10001111100011111000111110001000"),
("10000000100000001000100010001000"),
("10000000100000001000100010001000"),
("10000000100000001000100010001000"),
("10001000100010001111100011111000"),
("10001000100010001000000000001000"),
("10001000100010001000000000001000"),
("10001000100010001000000000001000"),
("10001111100011111000100010001000"),
("10000000100000000000100010001000"),
("10000000100000000000100010001000"),
("10000000100000000000100010001000"),
("11111111111111111111111110001000"),
("00000000000000000000000000000000"),
("00000000000000000000000000000000"),
("00000000000000000000000000000000")
	);
	
	
   signal Maze5 : MazeArray := (
("11111111111111111111111111111000"),
("10000000100000000000000000001000"),
("10000000100000000000000000001000"),
("10000000100000000000000000001000"),
("10001111111110001111100010001000"),
("10000000000000001000000010001000"),
("10000000000000001000000010001000"),
("10000000000000001000000010001000"),
("10001111100011111000111110001000"),
("10000000100000001000100010001000"),
("10000000100000001000100010001000"),
("10000000100000001000100010001000"),
("10001000100010001111100011111000"),
("10001000100010001000000000001000"),
("10001000100010001000000000001000"),
("10001000100010001000000000001000"),
("10001111100011111000100010001000"),
("10000000100000000000100010001000"),
("10000000100000000000100010001000"),
("10000000100000000000100010001000"),
("11111111111111111111111110001000"),
("00000000000000000000000000000000"),
("00000000000000000000000000000000"),
("00000000000000000000000000000000")
	);
	
	
   signal Maze6 : MazeArray := (

("11111111111111111111111111111000"),
("10000000000000000000000000001000"),
("10000000000000000000000000001000"),
("10000000000000000000000000001000"),
("10001111111110001000100010001000"),
("10000000000010001000100010001000"),
("10000000000010001000100010001000"),
("10000000000010001000100010001000"),
("11111000111111111111100010001000"),
("10001000000000000000100010001000"),
("10001000000000000000100010001000"),
("10001000000000000000100010001000"),
("10001000111110001000111111111000"),
("10000000100000001000000000001000"),
("10000000100000001000000000001000"),
("10000000100000001000000000001000"),
("11111000100011111111100010001000"),
("10000000100000001000000010001000"),
("10000000100000001000000010001000"),
("10000000100000001000000010001000"),
("11111111111111111111111110001000"),
("00000000000000000000000000000000"),
("00000000000000000000000000000000"),
("00000000000000000000000000000000")
	);
	
	
   signal Maze7 : MazeArray := (
	("11111111111111111111111111111000"),
("10000000000000000000000000001000"),
("10000000000000000000000000001000"),
("10000000000000000000000000001000"),
("11111000111111111000111110001000"),
("10000000000000001000000010001000"),
("10000000000000001000000010001000"),
("10000000000000001000000010001000"),
("10001111111110001111100011111000"),
("10000000000010000000100000001000"),
("10000000000010000000100000001000"),
("10000000000010000000100000001000"),
("11111000100010001111111111111000"),
("10000000100010000000000000001000"),
("10000000100010000000000000001000"),
("10000000100010000000000000001000"),
("10001111111111111000111110001000"),
("10001000000000000000000010001000"),
("10001000000000000000000010001000"),
("10001000000000000000000010001000"),
("11111111111111111111111110001000"),
("00000000000000000000000000000000"),
("00000000000000000000000000000000"),
("00000000000000000000000000000000")
	);
	
	
   signal Maze8 : MazeArray := (
("11111111111111111111111111111000"),
("10000000000000000000100000001000"),
("10000000000000000000100000001000"),
("10000000000000000000100000001000"),
("10001111111111111111111110001000"),
("10000000000000000000100000001000"),
("10000000000000000000100000001000"),
("10000000000000000000100000001000"),
("10001111111110001000100011111000"),
("10000000100010001000000000001000"),
("10000000100010001000000000001000"),
("10000000100010001000000000001000"),
("10001000100010001111111111111000"),
("10001000000010000000000000001000"),
("10001000000010000000000000001000"),
("10001000000010000000000000001000"),
("10001000111111111111111111111000"),
("10001000000000000000000000001000"),
("10001000000000000000000000001000"),
("10001000000000000000000000001000"),
("11111111111111111111111110001000"),
("00000000000000000000000000000000"),
("00000000000000000000000000000000"),
("00000000000000000000000000000000")
	);
	
	
   signal Maze9 : MazeArray := (
("11111111111111111111111111111000"),
("10000000000000000000000000001000"),
("10000000000000000000000000001000"),
("10000000000000000000000000001000"),
("10001000111110001111100011111000"),
("10001000000010000000100000001000"),
("10001000000010000000100000001000"),
("10001000000010000000100000001000"),
("11111000100011111111111111111000"),
("10000000100000000000000000001000"),
("10000000100000000000000000001000"),
("10000000100000000000000000001000"),
("10001111100011111111111110001000"),
("10000000100000001000100000001000"),
("10000000100000001000100000001000"),
("10000000100000001000100000001000"),
("10001111100010001000111110001000"),
("10001000000010000000100000001000"),
("10001000000010000000100000001000"),
("10001000000010000000100000001000"),
("11111111111111111111111110001000"),
("00000000000000000000000000000000"),
("00000000000000000000000000000000"),
("00000000000000000000000000000000")
	);
  
  
    signal themaze : rand := (Maze1,Maze,Maze2,Maze3,Maze4,Maze5,Maze6,Maze7,Maze8,Mazex);
	 signal i : MazeArray := Maze;


    signal square_x : integer range 0 to MazeWidth-1 := 1;
    signal square_y : integer range 0 to MazeHeight-1 := 1;

    signal move_enable : STD_LOGIC := '0';
    signal move_counter : integer := 0;

begin

    -- VGA timing process
    process(clk, reset)
    begin
        if reset = '0' or end_game = '1' then
            h_count <= 0;
            v_count <= 0;
        elsif rising_edge(clk) then
            if h_count = H_TOTAL-1 then
                h_count <= 0;
                if v_count = V_TOTAL-1 then
                    v_count <= 0;
                else
                    v_count <= v_count + 1;
                end if;
            else
                h_count <= h_count + 1;
            end if;
        end if;
    end process;


 main: process (clk,reset)
  
		-- maximal length 32-bit xnor LFSR 
		function generate_random_number(g : std_logic_vector(7 downto 0)) return integer is 
			variable f :  std_logic_vector(7 downto 0) := "00101110";
		begin 
			f := g(6 downto 0) & (g(7) xor g(5) xor g(4) xor g(3));
			return to_integer(unsigned(f));
		end function; 
  

		-- make dir shuffle	
		function Shuffle(input_array: rand) return rand is
			variable shuffled_array: rand := input_array;
			variable temp: MazeArray;
			variable j: integer;
		begin      
			for k in input_array'length - 1 downto 1 loop       
				j := generate_random_number("01101001") mod (10);
				temp := shuffled_array(k);
				shuffled_array(k) := shuffled_array(j);
				shuffled_array(j) := temp;
			end loop;
			return shuffled_array;
		end function Shuffle;
	
	 variable themazetemp : rand := themaze;
    variable itemp : MazeArray := i;
	
	begin
		if reset = '0' or end_game ='1' then 
			themazetemp := Shuffle(themazetemp);
			itemp := themazetemp(generate_random_number("00111010") mod 10);
			else
				i <= itemp;
			end if;
		i <= itemp;
	end process;


    -- Generate sync signals
    hsync <= '0' when (h_count >= H_RES + H_FP and h_count < H_RES + H_FP + H_SYNC_PULSE) else '1';
    vsync <= '0' when (v_count >= V_RES + V_FP and v_count < V_RES + V_FP + V_SYNC_PULSE) else '1';

    -- Active video region
    active_video <= '1' when (h_count < H_RES and v_count < V_RES) else '0';
    pixel_x <= h_count;
    pixel_y <= v_count;

    -- Movement control clock divider
    process(clk)
    begin
        if rising_edge(clk) then
            if move_counter = 4608000 then
                move_counter <= 0;
                move_enable <= '1';
            else
                move_counter <= move_counter + 1;
                move_enable <= '0';
            end if;
        end if;
    end process;

    -- Square position update
    process(clk, reset)
    begin
	 
        if reset = '0' or end_game = '1' then
				health <= 5;
				lose <= false;
				win <= false;
            square_x <= 1;
            square_y <= 1;
        elsif rising_edge(clk) and move_enable = '1' then
            
				if btn_up = '0' then
					if i(square_y-1, square_x) = '0' then
                square_y <= square_y - 1;
					 else
						health <= health - 1;
					 end if;
					 
            elsif btn_down = '0' then 
				 if i(square_y+1, square_x) = '0' then
                square_y <= square_y + 1;
					 else 
						health <= health - 1;
					 end if;
					 
            elsif btn_left = '0' then
				if i(square_y, square_x-1) = '0' then
                square_x <= square_x - 1;
					 else 
						health <= health - 1;
					 end if;
					 
            elsif btn_right = '0' then
				if i(square_y, square_x+1) = '0' then
                square_x <= square_x + 1;
					 else 
						health <= health - 1;
					 end if;
				else 
					square_x <= square_x;
					square_y <= square_y;
            end if;
				
				if health = 0 then
						lose <= true;
				end if;
				
				if (health > 0 and 60 >= timer_game) and square_y >= 20 then
					   win <= true;
				end if;
				
		  end if;
    end process;
	 
	 
	 process (health)
	 begin
				if (health = 5) then
					Leds (4 downto 0) <= "11111";
				elsif (health = 4) then
					Leds (4 downto 0) <= "11110";
				elsif (health = 3) then
					Leds (4 downto 0) <= "11100";
				elsif (health = 2) then
					Leds (4 downto 0) <= "11000";
				elsif (health = 1) then
					Leds (4 downto 0) <= "10000";
				else 
					Leds (4 downto 0) <= "11111";
					
		end if;		
	 end process;
	 
	 
	 
	  --change selector to choose one of segments each time
	 process(clk) 
	 variable counter : integer range 0 to 5000 :=0;
	 begin
		 if(rising_edge(clk)) then 
			 counter := counter +1;
			 if (counter = 4999) then 
				 counter :=0;
			    seg_selectors <= seg_selectors(0) & seg_selectors(3 downto 1);
			 end if;
		 end if;
	 end process;
	 
	 -- Timer of game : clock is 24mhz so 1s occurs after 24000000 clock edge
	 process(clk,reset) 
	 variable flag_key :bit:= '0';
	 variable flag_rst :bit:= '0';
	 variable counter : integer range 0 to 24000000 :=0;
	 begin
	    if reset = '0' or end_game = '1' then
		 flag_key := '0';
		 counter := 0;
		 timer_game <= 0;
		 elsif(rising_edge(clk)) then 
		  if(btn_up = '0' or btn_down = '0' or btn_right = '0' or btn_left = '0')then
	      flag_key := '1';
		  end if;
	     if (flag_key = '1') then
			 counter := counter + 1;
			 if (counter = 23999999) then 
				 counter := 0;
			 if( end_game = '1') then 
				timer_game <= 0;
			 else
			    timer_game <= timer_game + 1; --Add timer after 24000000 clk edge
			 end if;
			 end if;
			 end if;
		 end if;
	 end process;
	 
	 --this process detects when game is finished . in three case it happens : 
	 --1.(win) 2.timer_game(time is end) 3.lose = true 
	 process(timer_game)
	 begin
		if(timer_game = 60 or lose = true or win = true)then
			end_game <= '1';
		else
		   end_game <= '0';
		end if;
	 end process;

     outseg <= seg_selectors;	 

    --seg_selectors choose one segment and segx has content of each segment
	 process(seg_selectors,seg0,seg1,seg2,seg3 )
	 begin
		case seg_selectors is
			when "1110" =>
			sevenSegments <= seg0;
			when "0111" =>
			sevenSegments <= seg3;
			when "1011" =>
			sevenSegments <= seg2;
			when "1101" =>
			sevenSegments <= seg1;
			when others =>
			sevenSegments <= x"c0";
		end case;
	end process;
	
	
	
	process( reset,clk )
	variable flag_key : bit := '0';--flag = 0 -> button is not pressed, flag = 1-> button is pressed
	begin
	--here content of segments is "5632"
	if reset = '0' then
			-- display IDs
			seg0 <= x"92";
			seg1 <= x"82";
		 	seg2 <= x"B0";
	    	seg3 <= x"A4";
			flag_key := '0';
	elsif(rising_edge(clk)) then 
	
	if( btn_up = '0' or btn_down = '0' or btn_right = '0' or btn_left = '0' )then
	      flag_key := '1';
	else flag_key := '0';
	end if;
	
	  if( timer_game >= 90)then
	   input <= timer_game - 90; --to calculate firs digit of timer
		seg1 <= output;
		seg0 <= x"98";
	 elsif( timer_game >= 80)then
	   input <= timer_game - 80;
		seg1 <= output;
		seg0 <= x"80";
	 elsif( timer_game >= 70)then
	   input <= timer_game - 70;
		seg1 <= output;
		seg0 <= x"F8";
	 elsif( timer_game >= 60)then
	   input <= timer_game - 60;
		seg1 <= output;
		seg0 <= x"82";
	 elsif( timer_game >= 50)then
	   input <= timer_game - 50;
		seg1 <= output;
		seg0 <= x"92";
	 elsif( timer_game >= 40)then
	   input <= timer_game - 40;
		seg1 <= output;
		seg0 <= x"99";
	 elsif( timer_game >= 30)then
	   input <= timer_game - 30;
		seg1 <= output;
		seg0 <= x"B0";
	 elsif( timer_game >= 20)then
	   input <= timer_game - 20;
		seg1 <= output;
		seg0 <= x"A4";
	 elsif( timer_game >= 10)then
	   input <= timer_game - 10;
		seg1 <= output;
		seg0 <= x"F9";
	 else
	   input <= timer_game;
		seg1 <= output;
		seg0 <= x"C0";
	 end if;
	end if;
	if(lose= true or timer_game = 60) then
		--lose
		seg0 <= x"c7";
		seg1 <= x"c0";
		seg2 <= x"92";
	   seg3 <= x"86";  
   end if;
	if(win= true) then
		--sucs
	   seg0 <= x"92";
	   seg1 <= x"c1";
		seg2 <= x"c6";
	   seg3 <= x"c6";
	end if;
	end process;
	
	--equal value of integer input in binary format to send to segment
  process (input)
  begin
  case input is
 	when 0 => output <= x"c0";
	when 1 => output <= x"F9";
	when 2 => output <= x"A4";
	when 3 => output <= x"B0";
	when 4 => output <= x"99";
	when 5 => output <= x"92";
	when 6 => output <= x"82";
	when 7 => output <= x"F8";
	when 8 => output <= x"80";
	when others => output <= x"98";
  end case;
  end process;
	 
	


    -- Pixel color generation
    process(pixel_x, pixel_y)
    begin
        if active_video = '1' then
		  
            if pixel_x / CellWidth = square_x and pixel_y / CellHeight = square_y then
                red   <= "11";  -- Red for square
                green <= "00";
                blue  <= "00";
            elsif i(pixel_y / CellHeight, pixel_x / CellWidth) = '1' then
                red   <= "11";  -- White for walls
                green <= "11";
                blue  <= "11";
            else
                red   <= "00";  -- Black for paths
                green <= "00";
                blue  <= "00";
            end if;
         else
               red   <= "00";
               green <= "00";
               blue  <= "11";
        
		  end if;
    end process;

end Behavioral;
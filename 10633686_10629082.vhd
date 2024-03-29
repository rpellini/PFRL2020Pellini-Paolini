-----------------------------------------
-- Authors: Riccardo Pellini, 10633686 --
--          Giuseppe Paolini, 10619082 --
-- Progetto Reti Logiche               --
-- AA 2019-2020                        --
-- Politecnico di Milano               --
-----------------------------------------




library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity project_reti_logiche is
    Port ( 
        i_clk     : in std_logic;
        i_start   : in std_logic;
        i_rst     : in std_logic;
        i_data    : in std_logic_vector(7 downto 0);
        o_address : out std_logic_vector(15 downto 0);
        o_done    : out std_logic;
        o_en      : out std_logic;
        o_we      : out std_logic;
        o_data    : out std_logic_vector(7 downto 0)
    );
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is
    type state_type is (RESET, START, WAIT_RAM, SAVE_ADDR, GET_WZ, SAVE_WZ, SUBTRACT, CHECK, WRITE, ENCODE, DONE, ENDSTATE);
    
    signal next_state, curr_state: state_type;
    signal target, target_reg, curr_Wz, curr_Wz_reg : std_logic_vector(7 downto 0); 
    signal last_Wz, last_Wz_reg : std_logic_vector(2 downto 0);
    signal targetAcquired, targetAcquired_reg, no_Wz, no_Wz_reg : std_logic;
    signal check_Wz, check_Wz_reg : signed(7 downto 0);
    signal counter, counter_reg : std_logic_vector(2 downto 0); 
    
begin 
    
    state_reg: process(i_clk, i_rst)    --, i_data, target, targetAcquired, curr_Wz, last_Wz, no_Wz, check_Wz)
    begin
        if i_rst = '1' then 
            curr_state <= RESET;
        elsif rising_edge(i_clk) then 
            curr_state <= next_state;
            target_reg <= target;
            curr_Wz_reg <= curr_Wz;
            last_Wz_reg <= last_Wz;
            targetAcquired_reg <= targetAcquired;
            no_Wz_reg <= no_Wz;
            check_Wz_reg <= check_Wz;
            counter_reg <= counter;
            
       end if;
   end process;
   
   WZ_analysis: process(curr_state, i_start, i_data, target_reg, targetAcquired_reg, curr_Wz_reg, last_Wz_reg, no_Wz_reg, check_Wz_reg, counter_reg) 

   begin 
        no_Wz <= no_Wz_reg;
        targetAcquired <= targetAcquired_reg;
        target <= target_reg;
        curr_Wz <= curr_Wz_reg;
        counter <= counter_reg;
        last_Wz <= last_Wz_reg; 
        check_Wz <= check_Wz_reg;
        o_en <= '0';
        o_we <= '0';
        o_done <= '0';
        o_data <= "10000000";
        
        case curr_state is
            when RESET => 
                o_address <= "0000000000000000";
                no_Wz <= '0';
                targetAcquired <= '0';
                target <= "00000000";
                curr_Wz <= "00000000";
                counter <= "000";
                last_Wz <= "000"; 
                check_Wz <= "00000000";               
                if i_start = '1' then 
                    next_state <= START;
                else   
                    next_state <= RESET;
                end if;
            
            when START =>
                o_address <= x"0008";
                o_en <= '1';
                next_state <= WAIT_RAM;
                
            when WAIT_RAM => 
                
                o_en <= '1';
                
                if targetAcquired_reg = '1' then 
                    o_address <= "0000000000000" & std_logic_vector(unsigned(counter_reg) - "001");
                    next_state <= SAVE_WZ;
                else 
                    o_address <= x"0008";                    
                    next_state <= SAVE_ADDR;
                end if;
                
                targetAcquired <= '1';
                
                    
            when SAVE_ADDR =>
                o_address <= x"0008";
                target <= i_data;
                next_state <= GET_WZ;
                
            when GET_WZ =>                            
                
                case counter_reg is
                    
                    when "000" => 
                        o_address <= x"0000";
                        counter <= "001";

                        
                    when "001" => 
                        o_address <= x"0001";
                        counter <= "010";

                        
                    when "010" => 
                        o_address <= x"0002";
                        counter <= "011";

                        
                    when "011" => 
                        o_address <= x"0003";
                        counter <= "100";

                        
                    when "100" => 
                        o_address <= x"0004";
                        counter <= "101";

                        
                    when "101" => 
                        o_address <= x"0005";
                        counter <= "110";

                        
                    when "110" => 
                        o_address <= x"0006";
                        counter <= "111";

                        
                    when others => 
                        o_address <= x"0007";
                        counter <= "000";
                        no_Wz <= '1';
                        
                end case;
                o_en <= '1';
                next_state <= WAIT_RAM;      
                
            when SAVE_WZ =>
                o_address <= "0000000000000" & std_logic_vector(unsigned(counter_reg) - "001");
                curr_Wz <= i_data;
                next_state <= SUBTRACT;  
                   
            when SUBTRACT =>
                o_address <= "0000000000000" & std_logic_vector(unsigned(counter_reg) - "001");

                check_Wz <= SIGNED(target_reg) - SIGNED(curr_Wz_reg);
                next_state <= CHECK;
            
            when CHECK =>
                o_address <= "0000000000000" & std_logic_vector(unsigned(counter_reg) - "001");
                
                case check_Wz_reg is
                    when "00000000" =>
                         next_state <= ENCODE;
                         last_Wz <= std_logic_vector(unsigned(counter_reg) - "001");
                    when "00000001" =>
                         next_state <= ENCODE;
                         last_Wz <= std_logic_vector(unsigned(counter_reg) - "001");
                    when "00000010" =>
                         next_state <= ENCODE;
                         last_Wz <= std_logic_vector(unsigned(counter_reg) - "001");
                    when "00000011" =>
                         next_state <= ENCODE;
                         last_Wz <= std_logic_vector(unsigned(counter_reg) - "001");
                    when others => 
                        if no_Wz_reg = '1' then
                            next_state <= WRITE;  
                        else
                            next_state <= GET_WZ; 
                        end if;
                                 
                    end case; 
            
            when ENCODE =>
                case check_Wz_reg is
                    when "00000000" => target <= '1' & last_Wz_reg & "0001";
                    when "00000001" => target <= '1' & last_Wz_reg & "0010";
                    when "00000010" => target <= '1' & last_Wz_reg & "0100";
                    when others     => target <= '1' & last_Wz_reg & "1000";
                end case;
                
                o_address <= x"0009";
                next_state <= WRITE;
               
                            
            when WRITE =>
                o_data <=  target_reg;
                o_address <= x"0009";
                o_en <= '1';
                o_we <= '1';
                next_state <= DONE;
                
            when DONE =>
                o_address <= x"0009";
                o_data <= target_reg;
                o_done <= '1';
                next_state <= ENDSTATE;
              
            when ENDSTATE =>
                o_address <= x"0009";
                o_data <= target_reg;
                if i_start = '1' then
                    next_state <= ENDSTATE;
                else 
                    next_state <= RESET;
                end if; 
                o_done <= '1';
                         
        end case;    

end process;                            

end Behavioral;

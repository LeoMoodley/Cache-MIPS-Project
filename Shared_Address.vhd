library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package SharedAddressPkg is
    type Addrss is array (0 to 269) of STD_LOGIC_VECTOR(31 downto 0);
    shared variable IAddr : Addrss := (others => X"00000000"); -- Initialize with zeros
end SharedAddressPkg;

package body SharedAddressPkg is
end SharedAddressPkg;

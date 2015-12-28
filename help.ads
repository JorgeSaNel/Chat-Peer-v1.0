-- Jorge Santos Neila
-- Doble Grado en Sist. Telecomunicación + ADE

with Lower_Layer_UDP;
with Ada.Strings.Unbounded;

--------------------------------
-- Procedures for print HELP --
--------------------------------
package Help is
	package LLU renames Lower_Layer_UDP;
	package ASU renames Ada.Strings.Unbounded;
	
	procedure Message_h;

	procedure Message_LM;
	
	procedure Message_NB;
	
	procedure Change_debug;

	procedure Message_WAI(Nick: ASU.Unbounded_String; EP_H, EP_R: LLU.End_Point_Type);

	procedure Change_prompt;
	
	function Get_Prompt_Status return Boolean;

end Help;

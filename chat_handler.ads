-- Jorge Santos Neila
-- Doble Grado en Sist. Telecomunicación + ADE

with Ada.Calendar;

with Maps_Protector_G;
with Lower_Layer_UDP;
with Maps_G;

package Chat_Handler is
	package LLU renames Lower_Layer_UDP;
	type Message_Type is (Init, Reject, Confirm, Writer, Logout);

	function Print_EP(EP: LLU.End_Point_Type) return String;

	function Time_To_String(T: Ada.Calendar.Time) return String;


	package NP_Neighbors is new Maps_G (Key_Type   => LLU.End_Point_Type,
								  		Value_Type => Ada.Calendar.Time,
								  		Null_Key   => Null,
								  		Null_Value => Ada.Calendar.Time_Of(2000,1,1),
								  		Max_Length => 10,
								  		"="		 => LLU."=",
								  		Key_To_String   => Print_EP,
								  		Value_To_String => Time_To_String);

	type Seq_N_T is mod Integer'Last;
	package NP_Latest_Msgs is new Maps_G (Key_Type 	=> LLU.End_Point_Type,
									Value_Type 	=> Seq_N_T,
									Null_Key 	=> Null,
									Null_Value 	=> 0,
									Max_Length 	=> 50,
									"=" 			=> LLU."=",
									Key_To_String 	=> Print_EP,
									Value_To_String => Seq_N_T'Image);

	package Neighbors is new Maps_Protector_G (NP_Neighbors);
		subtype Keys_Array_Type is Neighbors.Keys_Array_Type;

	package Latest_Msgs is new Maps_Protector_G (NP_Latest_Msgs);

	N_List: Neighbors.Prot_Map;
	L_M_List: Latest_Msgs.Prot_Map;

	-- Handler para utilizar como parámetro en LLU.Bind en el cliente
	-- Este procedimiento NO debe llamarse explícitamente
	procedure Users_Handler (From: in LLU.End_Point_Type; To: in LLU.End_Point_Type; P_Buffer: access LLU.Buffer_Type);

end Chat_Handler;

-- Jorge Santos Neila
-- Doble Grado en Sist. Telecomunicación + ADE

with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Chat_Handler; use Chat_Handler;

-- This package just print RCV and Flood message --
---------------------------------------------------
package Debug_Message is
	package LLU renames Lower_Layer_UDP;
	package ASU renames Ada.Strings.Unbounded;
	package CH renames Chat_Handler;
	
	subtype Seq_N_T is CH.Seq_N_T;

	-- Procedures Print RCV --
	--------------------------
	procedure Print_RCV_Reject(EP_H: LLU.End_Point_Type; Nick: ASU.Unbounded_String);
		
	procedure Print_RCV_Init(EP_H_Creat, EP_H_Rsnd: LLU.End_Point_Type; Seq_N: CH.Seq_N_T; Nick: ASU.Unbounded_String);

	procedure Print_RCV_Writer(EP_H_Creat, EP_H: LLU.End_Point_Type; Seq_N: CH.Seq_N_T; Nick, Message: ASU.Unbounded_String);

	procedure Print_RCV_Confirm(EP_H_Creat, EP_H: LLU.End_Point_Type; Seq_N: CH.Seq_N_T; Nick: ASU.Unbounded_String);

	procedure Print_RCV_Logout(EP_H_Creat, EP_H: LLU.End_Point_Type; Seq_N: CH.Seq_N_T; Nick: ASU.Unbounded_String; Sent: Boolean);

	-- Procedures Print Flood --
	----------------------------
	procedure Print_Flood_Init (EP_H_Creat, EP_H: LLU.End_Point_Type; Seq_N: CH.Seq_N_T; Nick: ASU.Unbounded_String);

	procedure Print_Flood_Writer(EP_H_Creat, EP_H: LLU.End_Point_Type; Seq_N: CH.Seq_N_T; Nick_Name, Message: ASU.Unbounded_String);

	procedure Print_Flood_Confirm(EP_H_Creat, EP_H: LLU.End_Point_Type; Seq_N: CH.Seq_N_T; Nick: ASU.Unbounded_String);

	procedure Print_Flood_Logout(EP_H_Creat, EP_H: LLU.End_Point_Type; Seq_N: CH.Seq_N_T; Nick: ASU.Unbounded_String; Sent: Boolean);

end Debug_Message;

-- Jorge Santos Neila
-- Doble Grado en Sist. Telecomunicación + ADE

with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Chat_Handler; use Chat_Handler;

package Users is
	package LLU renames Lower_Layer_UDP;
	package ASU renames Ada.Strings.Unbounded;
	package CH renames Chat_Handler;	
	subtype Seq_N_T is CH.Seq_N_T;

	procedure Send_ALL_Neighbors (P_Buffer: access LLU.Buffer_Type);

	procedure Send_Except_One_Neighbor(P_Buffer: access LLU.Buffer_Type; EP_H_Rsnd: LLU.End_Point_Type);


	--Procedures Add // Remove [Neighbors - Latests_Message] --
	-----------------------------------------------------------
	procedure Add_LM (EP_H: LLU.End_Point_Type; Seq_N: Seq_N_T);

	procedure Delete_LM(EP_H: LLU.End_Point_Type);

	procedure Add_Neighbor(EP_H: LLU.End_Point_Type);

	procedure Delete_Neighbor(EP_H: LLU.End_Point_Type);

	-- Procedures Introduce Message_Type --
	---------------------------------------
	procedure Introduce_Reject(P_Buffer: access LLU.Buffer_Type; EP_H: LLU.End_Point_Type; Nick: ASU.Unbounded_String);

	procedure Introduce_Init(P_Buffer: access LLU.Buffer_Type; EP_H_Creat, EP_H_Rsnd, EP_R_Creat: LLU.End_Point_Type; 
							 Nick_Name: ASU.Unbounded_String; Seq_N: Seq_N_T);

	procedure Introduce_Writer(P_Buffer: access LLU.Buffer_Type; EP_H_Creat, EP_H_Rsnd: LLU.End_Point_Type;
							   Nick, Message: ASU.Unbounded_String; Seq_N: Seq_N_T);

	procedure Introduce_Confirm(P_Buffer: access LLU.Buffer_Type; EP_H_Creat, EP_H_Rsnd: LLU.End_Point_Type; 
								Nick_Name: ASU.Unbounded_String; Seq_N: Seq_N_T);

	
	procedure Introduce_Logout(P_Buffer: access LLU.Buffer_Type; EP_H_Creat, EP_H_Rsnd: LLU.End_Point_Type; 
							   Nick_Name: ASU.Unbounded_String; Seq_N: Seq_N_T; Confirm_Set: Boolean);

end Users;

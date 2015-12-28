-- Jorge Santos Neila
-- Doble Grado en Sist. Telecomunicación + ADE

with Ada.Text_IO;
with Ada.Calendar;
with Debug;
with Pantalla;

package body Users is
	package ATI renames Ada.Text_IO;
	use type LLU.End_Point_Type;

	-- It send the Buffer to ALL neighbors --
	-----------------------------------------
	procedure Send_ALL_Neighbors (P_Buffer: access LLU.Buffer_Type) is
		Keys_Array: CH.Neighbors.Keys_Array_Type;
	begin
		Keys_Array := CH.Neighbors.Get_Keys(CH.N_List);
		for I in 1..Keys_Array'Length loop
			if Keys_Array(I) /= null then
				Debug.Put_Line("        send to: " & CH.Print_EP(Keys_Array(I)));
				LLU.Send(Keys_Array(I), P_Buffer);
			end if;
		end loop;
	end Send_ALL_Neighbors;

	-- It send the Buffer to all neighbors except the node that had forwarded the message --
	-----------------------------------------------------------------------------------------
	procedure Send_Except_One_Neighbor(P_Buffer: access LLU.Buffer_Type; EP_H_Rsnd: LLU.End_Point_Type) is
		Keys_Array: CH.Neighbors.Keys_Array_Type;
	begin
		Keys_Array := CH.Neighbors.Get_Keys(CH.N_List);
		for I in 1..Keys_Array'Length loop
			if Keys_Array(I) /= null and Keys_Array(I) /= EP_H_Rsnd then
				Debug.Put_Line("        send to: " & CH.Print_EP(Keys_Array(I)));
				LLU.Send(Keys_Array(I), P_Buffer);
			end if;
		end loop;
	end Send_Except_One_Neighbor;

	--Print Add // Delete Lastest_Messages--
	----------------------------------------
	procedure Add_LM (EP_H: LLU.End_Point_Type; Seq_N: Seq_N_T) is
		Success: Boolean;
	begin
		CH.Latest_Msgs.Put(CH.L_M_List, EP_H, Seq_N, Success);
		if Success then
			Debug.Put_Line("Añadimos a latest_msgs " & CH.Print_EP(EP_H) & CH.Seq_N_T'Image(Seq_N));
		else
			Debug.Put_Line("Lista de mensajes llena", Pantalla.Rojo);
		end if;
	end Add_LM;

	procedure Delete_LM(EP_H: LLU.End_Point_Type) is
		Success: Boolean;
	begin
		CH.Latest_Msgs.Delete(CH.L_M_List, EP_H, Success);
		if Success then
			Debug.Put_Line("        Borramos de latest_msgs a " & CH.Print_EP(EP_H));
		end if;
	end Delete_LM;

	--Print Add // Delete Neighbor--
	--------------------------------
	procedure Add_Neighbor(EP_H: LLU.End_Point_Type) is
		Hour: Ada.Calendar.Time := Ada.Calendar.Clock;
		Success: Boolean;
	begin
		CH.Neighbors.Put(CH.N_List, EP_H, Hour, Success);
		if Success then
			Debug.Put_Line("Añadimos a neighbors " & CH.Print_EP(EP_H));
		else
			Debug.Put_Line("No hemos podido añadir a " & CH.Print_EP(EP_H));
			Debug.Put_Line("Numero de neighbors lleno", Pantalla.Rojo);
		end if;
	end Add_Neighbor;

	procedure Delete_Neighbor(EP_H: LLU.End_Point_Type) is
		Success: Boolean;
	begin
		CH.Neighbors.Delete(CH.N_List, EP_H, Success);
		if Success then
			Debug.Put_Line("        Borramos de neighbors " & CH.Print_EP(EP_H));
		end if;
	end Delete_Neighbor;

	--Introduce Reject data on the buffer--
	--That message is NOT send by flooding protocol--
	procedure Introduce_Reject(P_Buffer: access LLU.Buffer_Type; EP_H: LLU.End_Point_Type; Nick: ASU.Unbounded_String) is
	begin
		LLU.Reset(P_Buffer.all);
		CH.Message_Type'Output(P_Buffer, CH.Reject);
		LLU.End_Point_Type'Output(P_Buffer, EP_H);
		ASU.Unbounded_String'Output(P_Buffer, Nick);
	end Introduce_Reject;


	-- Procedures Introduce Message_Type --
	------------------------------------------------------
	-- All the message send by flood protocol have		--
		-- Message_Type									--
		-- EP_H_Creat: node that created the message	--
		-- Seq_N assigned by the node EP_H_Creat		--
		-- EP_H: Node that has forwarded the message	--
	-- We use for that the same procedure: Introduce	--
	------------------------------------------------------
	procedure Introduce(Mess: CH.Message_Type; P_Buffer: access LLU.Buffer_Type; EP_H_Creat, EP_H: LLU.End_Point_Type; Seq_N: Seq_N_T) is
	begin
		LLU.Reset(P_Buffer.all);
		CH.Message_Type'Output(P_Buffer, Mess);
		LLU.End_Point_Type'Output(P_Buffer, EP_H_Creat); --EP_H_Creat: node that created the message
		Seq_N_T'Output(P_Buffer, Seq_N); --Seq_N assigned by the node EP_H_Creat
		LLU.End_Point_Type'Output(P_Buffer, EP_H); --EP_H: node that has forwarded the message
	end Introduce;


	--Introduce Init Data on the Buffer --
	procedure Introduce_Init(P_Buffer: access LLU.Buffer_Type; EP_H_Creat, EP_H_Rsnd, EP_R_Creat: LLU.End_Point_Type; 
							 Nick_Name: ASU.Unbounded_String; Seq_N: Seq_N_T) is
	begin
		Introduce(CH.Init, P_Buffer, EP_H_Creat, EP_H_Rsnd, Seq_N);
		LLU.End_Point_Type'Output(P_Buffer, EP_R_Creat); --EP_R: node that created the message
		ASU.Unbounded_String'Output(P_Buffer, Nick_Name); --Nick of the node that created the message
	end Introduce_Init;

	--Introduce Writer Data on the Buffer --
	procedure Introduce_Writer(P_Buffer: access LLU.Buffer_Type; EP_H_Creat, EP_H_Rsnd: LLU.End_Point_Type;
							   Nick, Message: ASU.Unbounded_String; Seq_N: Seq_N_T) is
	begin
		Introduce(CH.Writer, P_Buffer, EP_H_Creat, EP_H_Rsnd, Seq_N);
		ASU.Unbounded_String'Output(P_Buffer, Nick); --Nick of the node that created the message
		ASU.Unbounded_String'Output(P_Buffer, Message);
	end Introduce_Writer;

	procedure Introduce_Confirm(P_Buffer: access LLU.Buffer_Type; EP_H_Creat, EP_H_Rsnd: LLU.End_Point_Type;
								Nick_Name: ASU.Unbounded_String; Seq_N: Seq_N_T) is
	begin
		Introduce(CH.Confirm, P_Buffer, EP_H_Creat, EP_H_Rsnd, Seq_N);
		ASU.Unbounded_String'Output(P_Buffer, Nick_Name); --Nick of the node that created the message
	end Introduce_Confirm;

	procedure Introduce_Logout(P_Buffer: access LLU.Buffer_Type; EP_H_Creat, EP_H_Rsnd: LLU.End_Point_Type; 
								Nick_Name: ASU.Unbounded_String; Seq_N: Seq_N_T; Confirm_Set: Boolean) is
	begin
		Introduce(CH.Logout, P_Buffer, EP_H_Creat, EP_H_Rsnd, Seq_N);
		ASU.Unbounded_String'Output(P_Buffer, Nick_Name); --Nick of the node that created the message
		Boolean'Output(P_Buffer, Confirm_Set);
	end Introduce_Logout;

end Users;

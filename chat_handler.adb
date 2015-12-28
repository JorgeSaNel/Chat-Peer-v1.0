-- Jorge Santos Neila
-- Doble Grado en Sist. Telecomunicación + ADE

with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Gnat.Calendar.Time_IO;
with Ada.Command_Line;

with Users;
with Debug;
with Pantalla;
with Debug_Message;

package body Chat_Handler is
	package ASU renames Ada.Strings.Unbounded;
	package DM renames Debug_Message;

	-- Print an End_Point_Type like => IP:Port => XX.XX.XX.XX : XXXX --
	function Print_IP_Port(S: ASU.Unbounded_String) return String is
		S_Final,S_IP, S_Port: ASU.Unbounded_String;
		N: Natural;
	begin
		N := ASU.Index(S, ":");
		S_Final := ASU.Tail(S, ASU.Length(S)-N-1);

		N := ASU.Index(S_Final, ",");
		S_IP := ASU.Head(S_Final, N-1);

		N := ASU.Index(S_Final, "  ");
		S_Port := ASU.Tail(S_Final, ASU.Length(S_Final)-N-1);

		S_Final := ASU.To_Unbounded_String(ASU.To_String(S_IP) & ":" & ASU.To_String(S_Port));
		return ASU.To_String(S_Final);
	end Print_IP_Port;

	function Print_EP (EP: LLU.End_Point_Type) return String is
		S: ASU.Unbounded_String;
	begin
		S := ASU.To_Unbounded_String(LLU.Image(EP));
		S := ASU.To_Unbounded_String(Print_IP_Port(S));
		return ASU.To_String(S);
	end Print_EP;

	-- Convert Time to String --
	function Time_To_String (T: Ada.Calendar.Time) return String is
		package C_IO renames Gnat.Calendar.Time_IO;
	begin
		return C_IO.Image(T, "%c");
	end Time_To_String;

	--------------------------
	--- Procedures Handler ---
	--------------------------

	function Must_Send(EP_Creat: LLU.End_Point_Type; Seq_N: Seq_N_T) return Boolean is
		use type Seq_N_T;
		Value: Seq_N_T;
		Success: Boolean;
	begin
		-- Check if we must send it by flooding protocol
		Latest_Msgs.Get(L_M_List, EP_Creat, Value, Success);
		if Success then
			if Seq_N > Value then return True;
				else return False;
			end if;
		else return True;
		end if;
	end Must_Send;

	procedure Get_Out_Init(P_Buffer: Access LLU.Buffer_Type; To: in LLU.End_Point_Type) is
		package ACL renames Ada.Command_Line;
		use type ASU.Unbounded_String;
		use type LLU.End_Point_Type;

		EP_H_Creat, EP_R_Creat, EP_H_Rsnd: LLU.End_Point_Type;
		Nick_Name: ASU.Unbounded_String;
		Seq_N: Seq_N_T;
	begin
		--Get out from P_Buffer--
		EP_H_Creat := LLU.End_Point_Type'Input(P_Buffer); --EP_H_Creat: node that created the message
		Seq_N := Seq_N_T'Input(P_Buffer); 				  --Seq_N assigned by the node EP_H_Creat
		EP_H_Rsnd := LLU.End_Point_Type'Input(P_Buffer);  --EP_H: node that has forwarded the message
		EP_R_Creat := LLU.End_Point_Type'Input(P_Buffer); --EP_R: node that created the message. For reject message
		Nick_Name := ASU.Unbounded_String'Input(P_Buffer);
		
		DM.Print_RCV_Init(EP_H_Creat, EP_H_Rsnd, Seq_N, Nick_Name);
		if ASU.To_String(Nick_Name) = ACL.Argument(2) then
			-- Send Reject Message to that who has the same Nick_Name --
			Debug.Put("    SEND Reject ", Pantalla.Amarillo);
			Debug.Put_Line(Print_EP(To) & " " & ASU.To_String(Nick_Name));

			Debug.Put("    ");
			Users.Add_LM(EP_H_Creat, Seq_N);
			Debug.Put("    ");
			Users.Add_Neighbor(EP_H_Creat);
			Debug.Put("    ");
			DM.Print_Flood_Init(EP_H_Creat, To, Seq_N, Nick_Name);

			Users.Introduce_Reject(P_Buffer, To, Nick_Name);
			LLU.Send(EP_R_Creat, P_Buffer);
		else
			-- Check if we must add a Neighbor
			if EP_H_Creat = EP_H_Rsnd then
				Debug.Put("    ");
				Users.Add_Neighbor(EP_H_Creat);
			end if;

			if Must_Send(EP_H_Creat, Seq_N) then
				Debug.Put("    ");
				Users.Add_LM(EP_H_Creat, Seq_N);
				Debug.Put("    ");
				DM.Print_Flood_Init(EP_H_Creat, To, Seq_N, Nick_Name);

				Users.Introduce_Init(P_Buffer, EP_H_Creat, To, EP_R_Creat, Nick_Name, Seq_N);
				Users.Send_Except_One_Neighbor(P_Buffer, EP_H_Rsnd);
			else
				Debug.Put("    NOFLOOD Init ", Pantalla.Amarillo);
				Debug.Put_Line(Print_EP(EP_H_Creat) & Seq_N_T'Image(Seq_N) & " " & Print_EP(To) & " " & ASU.To_String(Nick_Name));
			end if;
		end if;
	end Get_Out_Init;

	procedure Get_Out_Confirm(P_Buffer: access LLU.Buffer_Type; To: LLU.End_Point_Type) is
		EP_H_Creat, EP_H_Rsnd: LLU.End_Point_Type;
		Nick_Name: ASU.Unbounded_String;
		Seq_N: Seq_N_T;
	begin
		--Get out from P_Buffer--
		EP_H_Creat := LLU.End_Point_Type'Input(P_Buffer); --EP_H_Creat: node that created the message
		Seq_N := Seq_N_T'Input(P_Buffer); 				  --Seq_N assigned by the node EP_H_Creat
		EP_H_Rsnd := LLU.End_Point_Type'Input(P_Buffer);  --EP_H: node that has forwarded the message
		Nick_Name := ASU.Unbounded_String'Input(P_Buffer);
		
		DM.Print_RCV_Confirm(EP_H_Creat, EP_H_Rsnd, Seq_N, Nick_Name);
		if Must_Send(EP_H_Creat, Seq_N) then		
			Ada.Text_IO.Put_Line(ASU.To_String(Nick_Name) & " ha entrado en el chat");
			Debug.Put("    ");
			Users.Add_LM(EP_H_Creat, Seq_N);
			Debug.Put("    ");
			DM.Print_Flood_Confirm(EP_H_Creat, To, Seq_N, Nick_Name);

			Users.Introduce_Confirm(P_Buffer, EP_H_Creat, To, Nick_Name, Seq_N);
			Users.Send_Except_One_Neighbor(P_Buffer, EP_H_Rsnd);
		else
			Debug.Put("    NOFLOOD Confirm ", Pantalla.Amarillo);
			Debug.Put_Line(Print_EP(EP_H_Creat) & Seq_N_T'Image(Seq_N) & " " & Print_EP(EP_H_Rsnd) & " " & ASU.To_String(Nick_Name));
		end if;
	end Get_Out_Confirm;

	procedure Get_Out_Writer(P_Buffer: access LLU.Buffer_Type; To: LLU.End_Point_Type) is
		EP_H_Creat, EP_H_Rsnd: LLU.End_Point_Type;
		Message, Nick_Name: ASU.Unbounded_String;
		Seq_N: Seq_N_T;
	begin
		--Get out from P_Buffer--
		EP_H_Creat := LLU.End_Point_Type'Input(P_Buffer); --EP_H_Creat: node that created the message
		Seq_N := Seq_N_T'Input(P_Buffer);				  --Seq_N assigned by the node EP_H_Creat
		EP_H_Rsnd := LLU.End_Point_Type'Input(P_Buffer);  --EP_H: node that has forwarded the message
		Nick_Name := ASU.Unbounded_String'Input(P_Buffer);
		Message := Asu.Unbounded_String'Input(P_Buffer);

		DM.Print_RCV_Writer(EP_H_Creat, EP_H_Rsnd, Seq_N, Nick_Name, Message);
		if Must_Send(EP_H_Creat, Seq_N) then
			ADA.Text_IO.Put_Line(ASU.To_String(Nick_Name) & ": " & ASU.To_String(Message));
			Debug.Put("    ");
			Users.Add_LM(EP_H_Creat, Seq_N);
			Debug.Put("    ");
			DM.Print_Flood_Writer(EP_H_Creat, To, Seq_N, Nick_Name, Message);

			Users.Introduce_Writer(P_Buffer, EP_H_Creat, To, Nick_Name, Message, Seq_N);
			Users.Send_Except_One_Neighbor(P_Buffer, EP_H_Rsnd);
		else
			Debug.Put("    NOFLOOD Writer ", Pantalla.Amarillo);
			Debug.Put_Line(Print_EP(EP_H_Creat) & Seq_N_T'Image(Seq_N) & " " & Print_EP(EP_H_Rsnd) & " " & ASU.To_String(Nick_Name));
		end if;
	end Get_Out_Writer;

	function Has_Latest_Mssg(EP_Creat: LLU.End_Point_Type) return Boolean is
		Value: Seq_N_T;
		Success: Boolean;
	begin
		Latest_Msgs.Get(L_M_List, EP_Creat, Value, Success);
		return Success;	
	end Has_Latest_Mssg;

	procedure Get_Out_Logout(P_Buffer: access LLU.Buffer_Type; To: LLU.End_Point_Type) is
		use type LLU.End_Point_Type;
		EP_H_Creat, EP_H_Rsnd: LLU.End_Point_Type;
		Seq_N: Seq_N_T;
		Nick_Name: ASU.Unbounded_String;
		Confirm_Sent: Boolean;
	begin
		--Get out from P_Buffer--
		EP_H_Creat := LLU.End_Point_Type'Input(P_Buffer); --EP_H_Creat: node that created the message
		Seq_N := Seq_N_T'Input(P_Buffer);				  --Seq_N assigned by the node EP_H_Creat
		EP_H_Rsnd := LLU.End_Point_Type'Input(P_Buffer);  --EP_H: node that has forwarded the message
		Nick_Name := Asu.Unbounded_String'Input(P_Buffer);
		Confirm_Sent := Boolean'Input(P_Buffer);

		DM.Print_RCV_Logout(EP_H_Creat, EP_H_Rsnd, Seq_N, Nick_Name, Confirm_Sent);
		if Must_Send(EP_H_Creat, Seq_N) and Has_Latest_Mssg(EP_H_Creat) then
		
			Users.Delete_LM(EP_H_Creat);
			Users.Delete_Neighbor(EP_H_Creat);
			
			if Confirm_Sent then
				ADA.Text_IO.Put_Line(ASU.To_String(Nick_Name) & " ha abandonado el chat");
			end if;

			Debug.Put("        ");
			DM.Print_Flood_Logout(EP_H_Creat, To, Seq_N, Nick_Name, Confirm_Sent);

			Users.Introduce_Logout(P_Buffer, EP_H_Creat, To, Nick_Name, Seq_N, Confirm_Sent);
			Users.Send_Except_One_Neighbor(P_Buffer, EP_H_Rsnd);
		else
			Debug.Put("    NOFLOOD Logout ", Pantalla.Amarillo);
			Debug.Put_Line(Print_EP(EP_H_Creat) & Seq_N_T'Image(Seq_N) & " " & Print_EP(EP_H_Rsnd) & " " & ASU.To_String(Nick_Name));
		end if;
	end Get_Out_Logout;

	-- Argument To is equal than EP_H_Rsnd
	-- EP_H_Rsnd: node that has forwarded the message
	procedure Users_Handler (From: in LLU.End_Point_Type; To: in LLU.End_Point_Type; P_Buffer: access LLU.Buffer_Type) is
		use type Message_Type;
		Mess: Message_Type;
	begin
		Mess := Message_Type'Input(P_Buffer);
		if Mess = Init then
			Get_out_Init(P_Buffer, To);
		elsif Mess = Confirm then
			Get_Out_Confirm(P_Buffer, To);
		elsif Mess = Writer then
			Get_Out_Writer(P_Buffer, To);
		elsif Mess = Logout then
			Get_Out_Logout(P_Buffer, To);
		end if;
	end Users_Handler;

end Chat_Handler;

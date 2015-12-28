-- Jorge Santos Neila
-- Doble Grado en Sist. Telecomunicación + ADE

with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Ada.Strings.Unbounded.Text_IO;
with Ada.Command_Line;
with Ada.Exceptions;

with Lower_Layer_UDP;
with Chat_Handler;
with Pantalla;
with Debug;
with Help;
with Users;
with Debug_Message;

procedure Chat_Peer is
	package ATI renames ADA.Text_IO;
	package LLU renames Lower_Layer_UDP;
	package ASU renames Ada.Strings.Unbounded;
	package ACL renames Ada.Command_Line;
	package CH renames Chat_Handler;
	package DM renames Debug_Message;
	use type CH.Seq_N_T;	

	Port_Error: Exception;
	Port_Error_Neighbor_1: Exception;
	Port_Error_Neighbor_2: Exception;
	Usage_Error: Exception;

	procedure Print_Add_Neighbors (Neighbor_Host_1: in out ASU.Unbounded_String; Neighbor_Port_1: Natural;
								   Neighbor_Host_2: in out ASU.Unbounded_String; Neighbor_Port_2: Natural;
								   Are_N: out Boolean) is
		Neighbor_EP: LLU.End_Point_Type;
	begin
		if ACL.Argument_Count = 2 then
			Are_N := False;
		elsif ACL.Argument_Count >= 4 then
			Are_N := True;
			Neighbor_EP := LLU.Build(ASU.To_String(Neighbor_Host_1), Neighbor_Port_1);
			Users.Add_Neighbor(Neighbor_EP);

			if ACL.Argument_Count = 6 then
				Neighbor_EP := LLU.Build(ASU.To_String(Neighbor_Host_2), Neighbor_Port_2);
				Users.Add_Neighbor(Neighbor_EP);
			end if;
		end if;
	end Print_Add_Neighbors;

	procedure Arguments_Input(Port: out Natural; Nick_Name: out ASU.Unbounded_String;
							  Neighbor_Host_1: out ASU.Unbounded_String; Neighbor_Port_1: out Natural;
							  Neighbor_Host_2: out ASU.Unbounded_String; Neighbor_Port_2: out Natural) is
	begin
		if ACL.Argument_Count = 2 or ACL.Argument_Count = 4 or ACL.Argument_Count = 6 then
			Port := Integer'Value(ACL.Argument(1));
			Nick_Name := ASU.To_Unbounded_String(ACL.Argument(2));

			if Port < 1024 or Port > 65535 then
				raise Port_Error;
			end if;

			if ACL.Argument_Count >= 4 then
				Neighbor_Host_1 := ASU.To_Unbounded_String(ACL.Argument(3));
				Neighbor_Host_1 := ASU.To_Unbounded_String(LLU.To_IP(ASU.To_String(Neighbor_Host_1)));
				Neighbor_Port_1 := Integer'Value(ACL.Argument(4));

				if Neighbor_Port_1 < 1024 or Neighbor_Port_1 > 65535 then
					raise Port_Error_Neighbor_1;
				end if;
			end if;

			if ACL.Argument_Count = 6 then
				Neighbor_Host_2 := ASU.To_Unbounded_String(ACL.Argument(5));
				Neighbor_Host_2 := ASU.To_Unbounded_String(LLU.To_IP(ASU.To_String(Neighbor_Host_2)));
				Neighbor_Port_2 := Integer'Value(ACL.Argument(6));

				if Neighbor_Port_2 < 1024 or Neighbor_Port_2 > 65535 then
					raise Port_Error_Neighbor_2;
				end if;
			end if;
		else
			raise Usage_Error;
		end if;
	end Arguments_Input;

	procedure Read_String (Strings : out ASU.Unbounded_String; Nick: ASU.Unbounded_String) is
		package ASU_IO renames Ada.Strings.Unbounded.Text_IO;
		Prompt_Status: Boolean;
	begin
		Prompt_Status := Help.Get_Prompt_Status;
		if Prompt_Status then
			ATI.Put(ASU.To_String(Nick) & " >> ");
		end if;
		Strings := ASU_IO.Get_Line;
	end Read_String;

	-- This procedure read Strings and send it to all nodes --
	----------------------------------------------------------
	procedure Welcome_Message(P_Buffer: access LLU.Buffer_Type; EP_H, EP_R: LLU.End_Point_Type; 
							  Nick_Name:ASU.Unbounded_String; Seq_N: in out CH.Seq_N_T) is
		Message: ASU.Unbounded_String;
	begin
		ATI.Put_Line("Peer-Chat v1.0");
		ATI.Put_Line("==============");
		ATI.New_Line;
		ATI.Put_Line("Entramos en el chat con el Nick: " & ASU.To_String(Nick_Name));
		ATI.Put_Line(".h para help");

		while ASU.To_String(Message) /= ".salir" loop
    	   	Read_String(Message, Nick_Name);
			if ASU.To_String(Message) = ".h" or ASU.To_String(Message) = ".help" then
				Help.Message_h;
			elsif ASU.To_String(Message) = ".nb" or ASU.To_String(Message) = ".neighbors" then
				Help.Message_NB;
			elsif ASU.To_String(Message) = ".lm" or ASU.To_String(Message) = ".latest_msgs" then
				Help.Message_LM;
			elsif ASU.To_String(Message) = ".debug" then
				Help.Change_debug;
			elsif ASU.To_String(Message) = ".wai" or ASU.To_String(Message) = ".whoami" then
				Help.Message_WAI(Nick_Name, EP_H, EP_R);
			elsif ASU.To_String(Message) = ".prompt" then
				Help.Change_Prompt;
			elsif ASU.To_String(Message) = ".salir" then
				Seq_N := Seq_N + 1;
				Users.Add_LM(EP_H, Seq_N);

				DM.Print_Flood_Logout(EP_H, EP_H, Seq_N, Nick_Name, True); -- True becouse it has been admitted on admission protocol
				Users.Introduce_Logout(P_Buffer, EP_H, EP_H, Nick_Name, Seq_N, True);
				Users.Send_ALL_Neighbors(P_Buffer);

			else
				Seq_N := Seq_N + 1;
				Users.Add_LM(EP_H, Seq_N);

				DM.Print_Flood_Writer(EP_H, EP_H, Seq_N, Nick_Name, Message);
				Users.Introduce_Writer(P_Buffer, EP_H, EP_H, Nick_Name, Message, Seq_N);
				Users.Send_ALL_Neighbors(P_Buffer);
			end if;
		end loop;
	end Welcome_Message;

	procedure Reject_Message(P_Buffer: access LLU.Buffer_Type; EP_H: LLU.End_Point_Type; Seq_N: in out CH.Seq_N_T) is
		Mess: CH.Message_Type;
		EP_H_Logout: LLU.End_Point_Type;
		Nick_Name: ASU.Unbounded_String;
	begin            	
		Mess := CH.Message_Type'Input(P_Buffer);
		EP_H_Logout := LLU.End_Point_Type'Input(P_Buffer);
		Nick_Name := ASU.Unbounded_String'Input(P_Buffer);

		DM.Print_RCV_Reject(EP_H_Logout, Nick_Name);
		ATI.Put_Line("Usuario rechazado porque " & CH.Print_EP(EP_H_Logout) & " está usando el mismo nick");
		
		Seq_N := Seq_N + 1;
		DM.Print_Flood_Logout(EP_H, EP_H, Seq_N, Nick_Name, False); -- False becouse it has not been admitted on admission protocol
		Users.Introduce_Logout(P_Buffer, EP_H, EP_H, Nick_Name, Seq_N, False);
		Users.Send_ALL_Neighbors(P_Buffer);

		ATI.New_Line;
		Debug.Put_Line("Fin del Protocolo de Admisión");
	end Reject_Message;

	Port, Neighbor_Port_1, Neighbor_Port_2: Natural;
	Nick_Name, Neighbor_Host_1, Neighbor_Host_2: ASU.Unbounded_String;
	EP_R, EP_H: LLU.End_Point_Type;
	Buffer: aliased LLU.Buffer_Type(1024);
	Seq_N: CH.Seq_N_T := 0;
	Expired, Are_Neighbors: Boolean := True;
begin
	begin
		Arguments_Input(Port, Nick_Name, Neighbor_Host_1, Neighbor_Port_1, Neighbor_Host_2, Neighbor_Port_2);
		Print_Add_Neighbors(Neighbor_Host_1, Neighbor_Port_1, Neighbor_Host_2, Neighbor_Port_2, Are_Neighbors);

		EP_H := LLU.Build(LLU.To_IP(LLU.Get_Host_Name), Port);
		LLU.Bind(EP_H, CH.Users_Handler'Access); --Build a free Handler.End_Point
		LLU.Bind_Any(EP_R); --Build a free End_Point

		if Are_Neighbors then
			ATI.New_Line;
			Debug.Put_Line("Iniciando Protocolo de Admisión ...");
			
			Seq_N := Seq_N + 1;
			Users.Add_LM(EP_H, Seq_N);		
			DM.Print_Flood_Init(EP_H, EP_H, Seq_N, Nick_Name);
			Users.Introduce_Init(Buffer'Access, EP_H, EP_H, EP_R, Nick_Name, Seq_N);
			Users.Send_ALL_Neighbors(Buffer'Access); --Send to neighbors;

			LLU.Reset(Buffer);
			LLU.Receive(EP_R, Buffer'Access, 2.0, Expired);

            if Expired then
				ATI.New_Line;
				Seq_N := Seq_N + 1;
				Users.Add_LM(EP_H, Seq_N);
				DM.Print_Flood_Confirm(EP_H, EP_H, Seq_N, Nick_Name);

				Users.Introduce_Confirm(Buffer'Access, EP_H, EP_H, Nick_Name, Seq_N);
				Users.Send_ALL_Neighbors(Buffer'Access);
				ATI.New_Line;
				Debug.Put_Line("Fin del Protocolo de Admisión.");

				ATI.New_Line;
               	Welcome_Message(Buffer'Access, EP_H, EP_R, Nick_Name, Seq_N);
            else
            	Reject_Message(Buffer'Access, EP_H, Seq_N);
			end if;
		else
			Debug.Put_Line("No hacemos protocolo de admisión pues no tenemos contactos iniciales ...");
			Welcome_Message(Buffer'Access, EP_H, EP_R, Nick_Name, Seq_N);
		end if;

	exception
		when Usage_Error =>
			ATI.Put_Line("Argumentos Incorrectos: ./chat_peer port nickname [[host port] [host port]]");
		when Port_Error =>
			Debug.Put_Line("Puerto incorrecto [1024 < Port < 65535]", Pantalla.Rojo);
		when Port_Error_Neighbor_1 =>
			Debug.Put_Line("Puerto Neighbor_1 incorrecto [1024 < Port < 65535]", Pantalla.Rojo);
		when Port_Error_Neighbor_2 =>
			Debug.Put_Line("Puerto Neighbor_2 incorrecto [1024 < Port < 65535]", Pantalla.Rojo);
		when Ex:others =>
			Debug.Put_Line("Excepción imprevista: " & Ada.Exceptions.Exception_Name(Ex) & " en: " &
							Ada.Exceptions.Exception_Message(Ex), Pantalla.Rojo);
	end;
	LLU.Finalize;
end;

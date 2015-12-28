-- Jorge Santos Neila
-- Doble Grado en Sist. Telecomunicación + ADE

with Debug;
with Pantalla;

package body Debug_Message is

	-- Print RCV --
	---------------
	procedure Print_RCV_Reject(EP_H: LLU.End_Point_Type; Nick: ASU.Unbounded_String) is
	begin
		Debug.Put_Line("");
		Debug.Put("RCV Reject ", Pantalla.Amarillo);
		Debug.Put_Line(CH.Print_EP(EP_H) & " " & ASU.To_String(Nick));
	end Print_RCV_Reject;
	
	procedure Print_RCV_Init(EP_H_Creat, EP_H_Rsnd: LLU.End_Point_Type; Seq_N: CH.Seq_N_T; Nick: ASU.Unbounded_String) is
	begin
		Debug.Put_Line("");
		Debug.Put("RCV Init ", Pantalla.Amarillo);
		Debug.Put(CH.Print_EP(EP_H_Creat) & CH.Seq_N_T'Image(Seq_N) & " " & CH.Print_EP(EP_H_Rsnd)); 
		Debug.Put_Line(" ... " & ASU.To_String(Nick));
	end Print_RCV_Init;

	procedure Print_RCV_Writer(EP_H_Creat, EP_H: LLU.End_Point_Type; Seq_N: CH.Seq_N_T; Nick, Message: ASU.Unbounded_String) is
	begin
		Debug.Put_Line("");
		Debug.Put("RCV Writer ", Pantalla.Amarillo);
		Debug.Put(CH.Print_EP(EP_H_Creat) & CH.Seq_N_T'Image(Seq_N) & " " & CH.Print_EP(EP_H) & " " & ASU.To_String(Nick));
		Debug.Put_Line(" " & ASU.To_String(Message));
	end Print_RCV_Writer;

	procedure Print_RCV_Confirm(EP_H_Creat, EP_H: LLU.End_Point_Type; Seq_N: CH.Seq_N_T; Nick: ASU.Unbounded_String) is
	begin
		Debug.Put_Line("");
		Debug.Put("RCV Confirm ", Pantalla.Amarillo);
		Debug.Put(CH.Print_EP(EP_H_Creat) & CH.Seq_N_T'Image(Seq_N) & "  " & CH.Print_EP(EP_H));
		Debug.Put_Line(" " & ASU.To_String(Nick));
	end Print_RCV_Confirm;

	procedure Print_RCV_Logout(EP_H_Creat, EP_H: LLU.End_Point_Type; Seq_N: CH.Seq_N_T; Nick: ASU.Unbounded_String; Sent: Boolean) is
	begin
		Debug.Put_Line("");
		Debug.Put("RCV Logout ", Pantalla.Amarillo);
		Debug.Put(CH.Print_EP(EP_H_Creat) & CH.Seq_N_T'Image(Seq_N) & " " & CH.Print_EP(EP_H) & " " & ASU.To_String(Nick));
		Debug.Put_Line(" " & Boolean'Image(Sent));
	end Print_RCV_Logout;

	-- Print FLOODING --
	--------------------
	procedure Print_Flood_Init (EP_H_Creat, EP_H: LLU.End_Point_Type; Seq_N: CH.Seq_N_T; Nick: ASU.Unbounded_String) is
	begin
		Debug.Put("FLOOD Init ", Pantalla.Amarillo);
		Debug.Put(CH.Print_EP(EP_H_Creat) & CH.Seq_N_T'Image(Seq_N) & "  " & CH.Print_EP(EP_H));
		Debug.Put_Line(" ... " & ASU.To_String(Nick));
	end Print_Flood_Init;

	procedure Print_Flood_Writer(EP_H_Creat, EP_H: LLU.End_Point_Type; Seq_N: CH.Seq_N_T; Nick_Name, Message: ASU.Unbounded_String) is
	begin
		Debug.Put("FLOOD Writer ", Pantalla.Amarillo);
		Debug.Put(CH.Print_EP(EP_H_Creat) & CH.Seq_N_T'Image(Seq_N) & " " & CH.Print_EP(EP_H));
		Debug.Put_Line(" " & ASU.To_String(Nick_Name) & " " & ASU.To_String(Message));
	end Print_Flood_Writer;

	procedure Print_Flood_Confirm(EP_H_Creat, EP_H: LLU.End_Point_Type; Seq_N: CH.Seq_N_T; Nick: ASU.Unbounded_String) is
	begin
		Debug.Put("FLOOD Confirm ", Pantalla.Amarillo);
		Debug.Put(CH.Print_EP(EP_H_Creat) & CH.Seq_N_T'Image(Seq_N) & "  " & CH.Print_EP(EP_H));
		Debug.Put_Line(" ... " & ASU.To_String(Nick));
	end Print_Flood_Confirm;

	procedure Print_Flood_Logout(EP_H_Creat, EP_H: LLU.End_Point_Type; Seq_N: CH.Seq_N_T; Nick: ASU.Unbounded_String; Sent: Boolean) is
	begin
		Debug.Put("FLOOD Logout ", Pantalla.Amarillo);
		Debug.Put(CH.Print_EP(EP_H_Creat) & CH.Seq_N_T'Image(Seq_N) & " " & CH.Print_EP(EP_H) & " " & ASU.To_String(Nick));
		Debug.Put_Line(" " & Boolean'Image(Sent));
	end Print_Flood_Logout;

end Debug_Message;

-- Jorge Santos Neila
-- Doble Grado en Sist. Telecomunicación + ADE

with Chat_Handler;
with Pantalla;
with Debug;

package body Help is
	package CH renames Chat_Handler;

	--------------------------------
	-- Procedures for print HELP --
	--------------------------------
	Debug_Status: Boolean := True;
	Prompt_Status: Boolean := False;
	
	procedure Message_h is
	begin
		Debug_Status := Debug.Get_Status;
		Debug.Set_Status(True);

		Debug.Put_Line("              Comandos            Efectos", Pantalla.Rojo);
		Debug.Put_Line("              =================   =======", Pantalla.Rojo);
		Debug.Put_Line("              .nb .neighbors      lista de vecinos", Pantalla.Rojo);
		Debug.Put_Line("              .lm .latest_msgs    lista de últimos mensajes recibidos", Pantalla.Rojo);
		Debug.Put_Line("              .debug              toggle para info de debug", Pantalla.Rojo);
		Debug.Put_Line("              .wai .whoami        Muestra en pantalla: nick | EP_H | EP_R", Pantalla.Rojo);
		Debug.Put_Line("              .prompt             toggle para mostrar prompt", Pantalla.Rojo);
		Debug.Put_Line("              .h .help            muestra esta información de ayuda", Pantalla.Rojo);
		Debug.Put_Line("              .salir              termina el programa", Pantalla.Rojo);
		
		Debug.Set_Status(Debug_Status);
	end Message_h;

	procedure Change_debug is
	begin
		if Debug.Get_Status then
			Debug.Put_Line("Desactivada información de debug", Pantalla.Rojo);
			Debug.Set_Status(False);
		else
			Debug.Set_Status(True);
			Debug.Put_Line("Activada información de debug", Pantalla.Rojo);
		end if;
	end Change_debug;

	procedure Change_prompt is
	begin
		Debug_Status := Debug.Get_Status;
		Debug.Set_Status(True);

		if Prompt_Status then
			Debug.Put_Line("Desactivado el prompt", Pantalla.Rojo);
			Prompt_Status := False;
		else
			Debug.Put_Line("Activado el prompt", Pantalla.Rojo);
			Prompt_Status := True;
		end if;

		Debug.Set_Status(Debug_Status);
	end Change_prompt;

	function Get_Prompt_Status return Boolean is
	begin
		return Prompt_Status;
	end Get_Prompt_Status;

	procedure Message_LM is
	begin
		Debug_Status := Debug.Get_Status;
		Debug.Set_Status(True);

		Debug.Put_Line("                      Latest_Msgs", Pantalla.Rojo);
		CH.Latest_Msgs.Print_Map(CH.L_M_List);

		Debug.Set_Status(Debug_Status);
	end Message_LM;
	
	procedure Message_NB is
	begin
		Debug_Status := Debug.Get_Status;
		Debug.Set_Status(True);

		Debug.Put_Line("                      Neighbors", Pantalla.Rojo);
		CH.Neighbors.Print_Map(CH.N_List);

		Debug.Set_Status(Debug_Status);
	end Message_NB;

	procedure Message_WAI(Nick: ASU.Unbounded_String; EP_H, EP_R: LLU.End_Point_Type) is
	begin
		Debug_Status := Debug.Get_Status;
		Debug.Set_Status(True);

		Debug.Put_Line("Nick: " & ASU.To_String(Nick) & " | EP_H: " & CH.Print_EP(EP_H) & " | EP_R: " & CH.Print_EP(EP_R), Pantalla.Rojo);

		Debug.Set_Status(Debug_Status);
	end Message_WAI;
end Help;

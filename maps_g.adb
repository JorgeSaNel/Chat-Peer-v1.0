-- Jorge Santos Neila
-- Doble Grado en Sist. Telecomunicación + ADE

with Ada.Text_IO;
with Debug;
with Pantalla;
with Ada.Unchecked_Deallocation;

package body Maps_G is

	procedure Free is new Ada.Unchecked_Deallocation (Cell, Cell_A);


	procedure Get (M: Map; Key: Key_Type; Value: out Value_Type; Success: out Boolean) is
		P_Aux : Cell_A;
	begin
		P_Aux := M.P_First;
		Success := False;
		while not Success and P_Aux /= null Loop
			if P_Aux.Key = Key then
				Value := P_Aux.Value;
				Success := True;
			end if;
			P_Aux := P_Aux.Next;
		end loop;
	end Get;

	procedure Put (M: in out Map; Key: Key_Type; Value: Value_Type; Success: out Boolean) is
		P_Aux : Cell_A;
	begin
		Success := False;
		if M.Length /= Max_Length then
			-- Si ya existe Key, cambiamos su Value
			P_Aux := M.P_First;
			while not Success and P_Aux /= null loop
				if P_Aux.Key = Key then
					P_Aux.Value := Value;
					Success := True;
				end if;
				P_Aux := P_Aux.Next;
			end loop;

			-- Si no hemos encontrado Key añadimos al principio
			if not Success then
				if M.P_First = null then
					--Lista Vacia
					M.P_First := new Cell'(Key, Value, Null, Null);
					M.P_Last := M.P_First;
				else
					--Lista no Vacia
					M.P_Last.Next := new Cell'(Key, Value, M.P_Last, Null);
					M.P_Last := M.P_Last.Next;
				end if;
				Success := True;
				M.Length := M.Length + 1;
			end if;
		end if;
	end Put;

	procedure Delete (M: in out Map; Key: Key_Type; Success: out Boolean) is
		P_Current  : Cell_A;
	begin
		Success := False;
		P_Current := M.P_First;
		while not Success and P_Current /= null loop
			if P_Current.Key = Key then
				Success := True;
				M.Length := M.Length - 1;
				
				if P_Current /= M.P_First then
					P_Current.Prev.Next := P_Current.Next;
				else
					M.P_First := P_Current.Next;
				end if;

				if P_Current /= M.P_Last then
					P_Current.Next.Prev := P_Current.Prev;
				else
					M.P_Last := P_Current.Prev;
				end if;

				Free(P_Current);
			else
				P_Current := P_Current.Next;
			end if;
		end loop;
	end Delete;
	
	function Get_Keys (M: Map) return Keys_Array_Type is
		P_Aux: Cell_A;
		Keys: Keys_Array_Type := (others => Null_Key);
		i: Integer := 0;
	begin
		P_Aux := M.P_First;
		while P_Aux /= null loop
			i := i + 1;
			Keys(i) := P_Aux.Key;
			P_Aux := P_Aux.Next;
		end loop;
		return Keys;
	end Get_Keys;
	
	function Get_Values (M: Map) return Values_Array_Type is
		P_Aux: Cell_A;
		Values: Values_Array_Type := (others => Null_Value);
		i: Integer := 1;
	begin
		P_Aux := M.P_First;
		while P_Aux /= null loop
			Values(i) := P_Aux.Value;
			P_Aux := P_Aux.Next;
			i := i + 1;
		end loop;
		return Values;
	end Get_Values;

	function Map_Length (M: Map) return Natural is
	begin
		return M.Length;
	end Map_Length;

	procedure Print_Map (M: Map) is
		P_Aux : Cell_A;
	begin
		P_Aux := M.P_First;
		Debug.Put_Line ("                      --------------------", Pantalla.Rojo);
		while P_Aux /= null loop
			Debug.Put_Line("                      [ (" & Key_To_String(P_Aux.Key) & ")," & Value_To_String(P_Aux.Value)& " ]",
						   Pantalla.Rojo);
			P_Aux := P_Aux.Next;
		end loop;
	end Print_Map;

end Maps_G;

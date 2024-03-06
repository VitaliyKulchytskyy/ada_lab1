with Ada.Text_IO; use Ada.Text_IO;

with Parse_Args; use Parse_Args;

with Parse_Args.Integer_Array_Options;

procedure Lab1 is
    AP              : Argument_Parser;
    Num_Threads     : Integer := 1;
    Num_Step        : Long_Long_Integer;
    Exec_Time       : Integer;
    Stop_Permission : Boolean := False;

    pragma Atomic (Stop_Permission);

    task Break_Thread is
        entry Start;
        entry Quit;
    end Break_Thread;

    task type Sum_Thread is
        entry SetId (Id : Integer);
        entry Start;
    end Sum_Thread;

    task body Break_Thread is
    begin
        select
            accept Start;

            delay Duration (Exec_Time);
            Stop_Permission := True;
        or
            accept Quit;
        end select;
    end Break_Thread;

    task body Sum_Thread is
        Sum       : Long_Long_Integer := 0;
        Thread_Id : Integer           := 0;
    begin
        loop
            select
                accept Start;

                loop
                    Sum := Sum + Num_Step;
                    exit when Stop_Permission;
                end loop;

                Put_Line ("ID: " & Thread_Id'Img & " | Sum: " & Sum'Img);
                exit;
            or
                accept SetId (Id : Integer) do
                    Thread_Id := Id;
                end SetId;
            end select;
        end loop;
    end Sum_Thread;

    type Thread_Array is array (Integer range <>) of Sum_Thread;

begin
    AP.Add_Option
       (Make_Boolean_Option (False), "help", 'h',
        Usage => "Display this help text");
    AP.Add_Option
       (Make_Boolean_Option (False), "verbose", 'v',
        Usage => "Print verbose information");
    AP.Add_Option
       (Make_Integer_Option (1, Min => 1), "thread", 'n',
        Usage => "Set the number of threads");
    AP.Add_Option
       (Make_Integer_Option (1, Min => 1), "time", 't',
        Usage => "Set thread execution time (in seconds)");
    AP.Add_Option
       (Make_Integer_Option (1), "step", 's',
        Usage => "Set the sequence step value for all sums");
    AP.Set_Prologue ("Lab1");
    AP.Parse_Command_Line;

    if AP.Parse_Success and then AP.Boolean_Value ("help") then
        AP.Usage;
        Break_Thread.Quit;

    elsif AP.Parse_Success then
        Num_Threads := AP.Integer_Value ("thread");
        Num_Step    := Long_Long_Integer (AP.Integer_Value ("step"));
        Exec_Time   := AP.Integer_Value ("time");
        if AP.Boolean_Value ("verbose") then
            Put_Line ("Threads: " & Num_Threads'Img);
            Put_Line ("Step: " & Num_Step'Img);
            Put_Line ("Time: " & Exec_Time'Img & " sec.");
            Put_Line ("");
        end if;

        declare
            Threads_Arr : Thread_Array (1 .. Num_Threads);
            I           : Integer := 0;

        begin
            Break_Thread.Start;
            for I in Threads_Arr'Range loop
                Threads_Arr (I).SetId (I);
                Threads_Arr (I).Start;
            end loop;
        end;

    else
        Break_Thread.Quit;
        Put_Line
           ("Error while parsing command-line arguments: " & AP.Parse_Message);
    end if;
end Lab1;

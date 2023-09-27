pageextension 50400 "Cost Journal Extension" extends "Cost Journal"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {

        addafter(Post)
        {
            action("GetCosts")
            {
                Caption = 'Get Costs From API';
                ApplicationArea = All;
                Promoted = true;
                Image = GetLines;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    InsertLineFromAPI();
                end;
            }
        }

    }

    local procedure InsertLineFromAPI()
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
        JsonArray: JsonArray;
        Item: Text;
        i: Integer;
        IteamToken: JsonToken;
        AmountToken: JsonToken;

        ItemNo: Code[10];
        Amount: Decimal;
    begin
        if Client.Get('http://localhost:3000/costlist', Response) then
            if Response.IsSuccessStatusCode then begin
                Response.Content.ReadAs(Item);
                JsonArray.ReadFrom(Item);
                for i := 0 to JsonArray.Count - 1 do begin
                    JsonArray.Get(i, IteamToken);
                    JsonArray.Get(i, AmountToken);

                    /* Get the ID from the JSON object */
                    IteamToken.AsObject().Get('id', IteamToken);
                    ItemNo := IteamToken.AsValue().AsCode();

                    /* Get the Amount from the JSON object */
                    AmountToken.AsObject().Get('amount', AmountToken);
                    Amount := AmountToken.AsValue().AsDecimal();

                    InsertCostLine(ItemNo, Amount);
                end;
            end;

    end;


    local procedure InsertCostLine(ItemNo: Code[10]; amount: Decimal)
    var
        CostJournalLine: Record "Cost Journal Line";
        DocumentNo: Code[20];
    begin
        CostJournalLine.SetRange("Journal Template Name", 'COSTACCT');
        CostJournalLine.FindFirst();
        DocumentNo := CostJournalLine."Document No.";

        CostJournalLine.Init();
        CostJournalLine."Document No." := DocumentNo;
        CostJournalLine."Posting Date" := WORKDATE;
        CostJournalLine.Validate("Cost Type No.", ItemNo);
        CostJournalLine.Amount := amount;
        CostJournalLine."Journal Template Name" := 'COSTACCT';
        CostJournalLine."Journal Batch Name" := 'DEFAULT';
        CostJournalLine."Line No." := CostJournalLine.Count + 1000;
        CostJournalLine.Insert(true);
    end;

}

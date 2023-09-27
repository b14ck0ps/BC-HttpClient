page 50449 RandomJokes
{
    ApplicationArea = All;
    Caption = 'RandomJokes';
    PageType = Card;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(Jokes; Vjoke)
                {
                    ApplicationArea = All;
                    Caption = 'Jokes';
                    Editable = false;
                    Enabled = false;
                    ToolTip = 'Jokes';
                    MultiLine = true;
                }

            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Get new joke")
            {
                ApplicationArea = All;
                Caption = 'Get new joke';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    Vjoke := GetRandomJokes();
                end;
            }
        }
    }

    local procedure GetRandomJokes(): Text
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
        Json: JsonObject;
        Joke: Text;
    begin
        if Client.Get('https://v2.jokeapi.dev/joke/Programming?type=single', Response) then
            if Response.IsSuccessStatusCode then begin
                Response.Content.ReadAs(Joke);
                Json.ReadFrom(Joke);
                exit(GetValue(Json, 'joke'));
            end;
    end;


    local procedure GetValue(JsonObject: JsonObject; Field: Text): Text
    var
        Result: JsonToken;
    begin
        if JsonObject.Get(Field, Result) then
            exit(Result.AsValue().AsText());
    end;

    trigger OnOpenPage()
    begin
        Vjoke := GetRandomJokes();
    end;

    var
        Vjoke: Text;
}

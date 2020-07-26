
section Mango;

[DataSource.Kind="Mango", Publish="Mango.Publish"]
shared Mango.Data = Value.ReplaceType(Mango.Func, FuncType);

FuncType = type function (
    site_num as (type text meta [        
        Documentation.FieldCaption = "Mango account ID:",
         Documentation.SampleValues = {"12345"}
    ]),
    
    start as (type text meta [
        Documentation.FieldCaption = "Start date:",
        Documentation.FieldDescription = "Enter the first date of your statistics. You can specify date in YYYY-MM-DD format or use dynamic formats: today, yesterday, 69daysAgo.",
        Documentation.SampleValues = {"2020-02-28"}
    ]),
     end as (type text meta [
        Documentation.FieldCaption = "End date:",
        Documentation.FieldDescription = "Enter the last date of your statistics. You can specify date in YYYY-MM-DD format or use dynamic formats: today, yesterday, 69daysAgo.",
        Documentation.SampleValues = {"yesterday"}
    ])
    )
    as table meta [
        Documentation.Name = "Mango.Data Function",
        Documentation.LongDescription = "Created to get data from Mango Calltracking.",
        Documentation.Examples = {
        [
            Description = "Returns a list of records from Mango Calltracking",
            Code = "Mango.Data(""12345"",""2020-02-20"",""yesterday"")",
            Result = "{[Record1],[Record2],[Record3],...}"
        ],
        [
            Description = "Returns a list of records from Mango Calltracking",
            Code = "Mango.Data(""12346"",""500daysAgo"",""today"")",
            Result = "{[Record1],[Record2],[Record3],...}"
        ]
        }
    ];



Mango.Func =( site_num as text, start as text, end as text)=>
 let 
     
     startCalc=
       let
       x = Number.From(Date.From(dateFunc(end))-Date.From(dateFunc(start))),
       Source = List.Dates(Date.From(dateFunc(start)), x+1, #duration(1, 0, 0, 0)),
       #"Converted to Table" = Table.FromList(Source, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
       #"Changed Type" = Table.TransformColumnTypes(#"Converted to Table",{{"Column1", type date}}),
       #"Renamed Columns" = Table.RenameColumns(#"Changed Type",{{"Column1", "DimDate"}}),
        #"Вставлено: месяц" = Table.AddColumn(#"Renamed Columns", "Месяц", each Date.Month([DimDate]), Int64.Type),
        #"Вставлено: год" = Table.AddColumn(#"Вставлено: месяц", "Год", each Date.Year([DimDate]), Int64.Type),
        #"Удаленные дубликаты" = Table.Distinct(#"Вставлено: год", {"Месяц", "Год"}),
        #"Удаленные столбцы" = Table.RemoveColumns(#"Удаленные дубликаты",{"Месяц", "Год"}),
        #"Измененный тип" = Table.TransformColumnTypes(#"Удаленные столбцы",{{"DimDate", type text}}),
        #"Разделить столбец по разделителю" = Table.SplitColumn(#"Измененный тип", "DimDate", Splitter.SplitTextByDelimiter(".", QuoteStyle.Csv), {"DimDate.1", "DimDate.2", "DimDate.3"}),
        #"Добавлен пользовательский объект" = Table.AddColumn(#"Разделить столбец по разделителю", "DimDate", each [DimDate.3]&"-"&[DimDate.2]&"-"&[DimDate.1]),
        #"Другие удаленные столбцы" = Table.SelectColumns(#"Добавлен пользовательский объект",{"DimDate"}),
        #"Переименованные столбцы" = Table.RenameColumns(#"Другие удаленные столбцы",{{"DimDate", "DimDate1"}}),
        #"Добавлен индекс" = Table.AddIndexColumn(#"Переименованные столбцы", "Индекс", 1, 1),
        #"Измененный тип1" = Table.TransformColumnTypes(#"Добавлен индекс",{{"DimDate1", type text}})
        in
        #"Измененный тип1",
    
        endCalc=
        let
        x =  Number.From(Date.From(dateFunc(end))-Date.From(dateFunc(start))),
        Source = List.Dates(Date.From(dateFunc(end)), x+1, #duration(-1, 0, 0, 0)),
        #"Converted to Table" = Table.FromList(Source, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
        #"Changed Type" = Table.TransformColumnTypes(#"Converted to Table",{{"Column1", type date}}),
        #"Renamed Columns" = Table.RenameColumns(#"Changed Type",{{"Column1", "DimDate"}}),
        #"Вставлено: месяц" = Table.AddColumn(#"Renamed Columns", "Месяц", each Date.Month([DimDate]), Int64.Type),
        #"Вставлено: год" = Table.AddColumn(#"Вставлено: месяц", "Год", each Date.Year([DimDate]), Int64.Type),
        #"Удаленные дубликаты" = Table.Distinct(#"Вставлено: год", {"Месяц", "Год"}),
        #"Удаленные столбцы" = Table.RemoveColumns(#"Удаленные дубликаты",{"Месяц", "Год"}),
        #"Измененный тип" = Table.TransformColumnTypes(#"Удаленные столбцы",{{"DimDate", type text}}),
        #"Разделить столбец по разделителю" = Table.SplitColumn(#"Измененный тип", "DimDate", Splitter.SplitTextByDelimiter(".", QuoteStyle.Csv), {"DimDate.1", "DimDate.2", "DimDate.3"}),
        #"Добавлен пользовательский объект" = Table.AddColumn(#"Разделить столбец по разделителю", "DimDate", each [DimDate.3]&"-"&[DimDate.2]&"-"&[DimDate.1]),
        #"Другие удаленные столбцы" = Table.SelectColumns(#"Добавлен пользовательский объект",{"DimDate"}),
        #"Переименованные столбцы" = Table.RenameColumns(#"Другие удаленные столбцы",{{"DimDate", "DimDate2"}}),
        #"Сортированные строки" = Table.Sort(#"Переименованные столбцы",{{"DimDate2", Order.Ascending}}),
        #"Добавлен индекс" = Table.AddIndexColumn(#"Сортированные строки", "Индекс", 1, 1),
        #"Измененный тип1" = Table.TransformColumnTypes(#"Добавлен индекс",{{"DimDate2", type text}})
        in
        #"Измененный тип1",

    
    
        
        get=(site_num as text, token as text, date1 as text, date2 as text) => 
        let
            Источник = Json.Document(Web.Contents("https://widgets-api.mango-office.ru",
            [ 
                RelativePath="v1/calltracking/" & site_num & "/calls",
                Query = [ 
                  dateStart =   date1,
                  dateEnd =   date2,
                  access_token = token
                       ]
            ])),
            #"Преобразовано в таблицу" = Table.FromList(Источник, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
            #"Развернутый элемент Column1" = Table.ExpandRecordColumn(#"Преобразовано в таблицу", "Column1", {"callId", "dateStart", "dateEnd", "callType", "callStatus", "number", "callerNumber", "duration", "waitDuration", "isNew", "isQuality", "isDuplicate", "uid", "gaCid", "yaCid", "rsCid", "utmSource", "utmMedium", "utmCampaign", "utmContent", "utmTerm", "countryCode", "regionCode", "city", "ip", "url", "firstUrl", "customParam", "device", "tags", "isLead"}, {"callId", "dateStart", "dateEnd", "callType", "callStatus", "number", "callerNumber", "duration", "waitDuration", "isNew", "isQuality", "isDuplicate", "uid", "gaCid", "yaCid", "rsCid", "utmSource", "utmMedium", "utmCampaign", "utmContent", "utmTerm", "countryCode", "regionCode", "city", "ip", "url", "firstUrl", "customParam", "device", "tags", "isLead"}),
            #"Извлеченные значения" = Table.TransformColumns(#"Развернутый элемент Column1", {"tags", each Text.Combine(List.Transform(_, Text.From), ","), type text})
        in
            #"Извлеченные значения",
     
               
        
        Источник = Table.NestedJoin(endCalc,{"Индекс"},startCalc,{"Индекс"},"Запрос1",JoinKind.LeftOuter),
        #"Развернутый элемент Запрос1" = Table.ExpandTableColumn(Источник, "Запрос1", {"DimDate1"}, {"DimDate1"}),
        #"Удаленные столбцы" = Table.RemoveColumns(#"Развернутый элемент Запрос1",{"Индекс"}),
        #"Переупорядоченные столбцы" = Table.ReorderColumns(#"Удаленные столбцы",{"DimDate1", "DimDate2"}),
        #"Измененный тип" = Table.TransformColumnTypes(#"Переупорядоченные столбцы",{{"DimDate1", type text}, {"DimDate2", type text}}),
        #"Добавлен пользовательский объект" = Table.AddColumn(#"Измененный тип", "Дата1", each [DimDate1]&"T00:00Z"),
        #"Добавлен пользовательский объект1" = Table.AddColumn(#"Добавлен пользовательский объект", "Дата2", each [DimDate2]&"T23:59Z"),
        #"Удаленные столбцы1" = Table.RemoveColumns(#"Добавлен пользовательский объект1",{"DimDate1", "DimDate2"}),
        #"Измененный тип1" = Table.TransformColumnTypes(#"Удаленные столбцы1",{{"Дата1", type text}, {"Дата2", type text}}),
        #"Добавлен пользовательский объект2" = Table.AddColumn(#"Измененный тип1", "Пользовательская", each get(site_num,Extension.CurrentCredential()[Key],[Дата1],[Дата2])),
    #"Удаленные ошибки" = Table.RemoveRowsWithErrors(#"Добавлен пользовательский объект2", {"Пользовательская"}),
        #"Развернутый элемент Пользовательская" = Table.ExpandTableColumn(#"Удаленные ошибки", "Пользовательская", {"callId", "dateStart", "dateEnd", "callType", "callStatus", "number", "callerNumber", "duration", "waitDuration", "isNew", "isQuality", "isDuplicate", "uid", "gaCid", "yaCid", "rsCid", "utmSource", "utmMedium", "utmCampaign", "utmContent", "utmTerm", "countryCode", "regionCode", "city", "ip", "url", "firstUrl", "customParam", "device", "tags", "isLead"}, {"callId", "dateStart", "dateEnd", "callType", "callStatus", "number", "callerNumber", "duration", "waitDuration", "isNew", "isQuality", "isDuplicate", "uid", "gaCid", "yaCid", "rsCid", "utmSource", "utmMedium", "utmCampaign", "utmContent", "utmTerm", "countryCode", "regionCode", "city", "ip", "url", "firstUrl", "customParam", "device", "tags", "isLead"}),
        #"Удаленные столбцы2" = Table.RemoveColumns(#"Развернутый элемент Пользовательская",{"Дата1", "Дата2"})
    in
        #"Удаленные столбцы2";


    


dateFunc= (dat)=>
       if dat = "yesterday" then Date.ToText(Date.AddDays(Date.From(DateTime.LocalNow()) , -1),"yyyy-MM-dd") 
       else if dat = "today" then Date.ToText(Date.From(DateTime.LocalNow()),"yyyy-MM-dd")
       else if (try Number.From(Text.BeforeDelimiter(dat,"daysAgo")) otherwise 0) >0 then Date.ToText(Date.AddDays(Date.From(DateTime.LocalNow()),-1*Number.From(Text.BeforeDelimiter(dat,"daysAgo"))),"yyyy-MM-dd") 
       else dat ;



Mango = [
    TestConnection = (dataSourcePath) => 
        { 
        "Mango.Data", 
        Json.Document(dataSourcePath)[site_num],
        Json.Document(dataSourcePath)[start],
        Json.Document(dataSourcePath)[end]
        },
    Authentication = [
                 Key = []
       ],
    Label = "Mango Connection"
];



Mango.Publish = [
    Beta = false,
    Category = "Other",
    ButtonText = { "Mango Connector", "Mango Help" },
    LearnMoreUrl = "https://www.youtube.com/channel/UCqSLNYLN_3mf6nA1Xf7fu1g/",
    SourceImage = Mango.Icons,
    SourceTypeImage = Mango.Icons
];



Mango.Icons = [
    Icon16 = { Extension.Contents("Mango16.png"), Extension.Contents("Mango20.png"), Extension.Contents("Mango24.png"), Extension.Contents("Mango32.png") },
    Icon32 = { Extension.Contents("Mango32.png"), Extension.Contents("Mango40.png"), Extension.Contents("Mango48.png"), Extension.Contents("Mango64.png") }
];

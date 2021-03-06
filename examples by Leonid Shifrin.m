(* ----------------------------------- NESTED ASSOCIATIONS ------------------------------------- *)

data = {<|"company" -> "AAPL", "date" -> {2013, 12, 26}, "open" -> 80.2231|>, <|"company" -> "AAPL", 
    "date" -> {2013, 12, 27}, "open" -> 79.6268|>, <|"company" -> "AAPL", "date" -> {2013, 12, 30}, 
    "open" -> 78.7252|>, <|"company" -> "AAPL",  "date" -> {2013, 12, 31}, "open" -> 78.2626|>, <|
    "company" -> "AAPL", "date" -> {2014, 1, 2}, "open" -> 78.4701|>, <|"company" -> "AAPL", 
    "date" -> {2014, 1, 3}, "open" -> 78.0778|>, <|"company" -> "MSFT", "date" -> {2013, 12, 26}, 
    "open" -> 36.6635|>, <|"company" -> "MSFT", "date" -> {2013, 12, 27}, "open" -> 37.0358|>, <|
    "company" -> "MSFT", "date" -> {2013, 12, 30}, "open" -> 36.681|>, <|"company" -> "MSFT", 
    "date" -> {2013, 12, 31}, "open" -> 36.8601|>, <|"company" -> "MSFT", "date" -> {2014, 1, 2}, 
    "open" -> 36.8173|>, <|"company" -> "MSFT", "date" -> {2014, 1, 3}, "open" -> 36.6658|>, <|"company" -> "GE", 
    "date" -> {2013, 12, 26}, "open" -> 27.2125|>, <|"company" -> "GE", "date" -> {2013, 12, 27}, 
    "open" -> 27.3698|>, <|"company" -> "GE", "date" -> {2013, 12, 30}, "open" -> 27.3708|>, <|
    "company" -> "GE", "date" -> {2013, 12, 31}, "open" -> 27.4322|>, <|"company" -> "GE", "date" -> {2014, 1, 2}, 
    "open" -> 27.394|>, <|"company" -> "GE", "date" -> {2014, 1, 3}, "open" -> 27.0593|>};

(* lets create a nested Association from this data structure (List of Associations to Nested Associations) from user specified
preferences  i.e. {{"date",1},{"date",2},{"company"}} *)
 
keyWrap[x_Integer] := x;
keyWrap[x_String] := Key[x];

groupByFunc[key_String]:= groupByFunc[{key}];
groupByFunc[{keyPath__}]:= With[{keys = Sequence @@ Map[keyWrap, {keyPath}]},
    GroupBy[Part[#, keys] &]
   ];


(* we do a functional composition of groupByFunc with Map in a recursive manner below. This enables groupByFunc's result to map
on a deeper level after each nesting *)
multiGroupBy[{}] := Identity;
multiGroupBy[specs : {_List ..}] := Map[multiGroupBy[Rest@specs]]@*groupByFunc[First@specs];

transform = multiGroupBy[{{"date", 1}, {"date", 2}, {"company"}}]; (* this produces groupByFunc which is mapped over the  *)

transform[data]
(* <|2013 -> <|12 -> <|"AAPL" -> {<|"company" -> "AAPL", 
        "date" -> {2013, 12, 26}, 
        "open" -> 80.2231|>, <|"company" -> "AAPL", 
        "date" -> {2013, 12, 27}, 
        "open" -> 79.6268|>, <|"company" -> "AAPL", 
        "date" -> {2013, 12, 30}, 
        "open" -> 78.7252|>, <|"company" -> "AAPL", 
        "date" -> {2013, 12, 31}, "open" -> 78.2626|>}, 
     "MSFT" -> {<|"company" -> "MSFT", "date" -> {2013, 12, 26}, 
        "open" -> 36.6635|>, <|"company" -> "MSFT", 
        "date" -> {2013, 12, 27}, 
        "open" -> 37.0358|>, <|"company" -> "MSFT", 
        "date" -> {2013, 12, 30}, 
        "open" -> 36.681|>, <|"company" -> "MSFT", 
        "date" -> {2013, 12, 31}, "open" -> 36.8601|>}, 
     "GE" -> {<|"company" -> "GE", "date" -> {2013, 12, 26}, 
        "open" -> 27.2125|>, <|"company" -> "GE", 
        "date" -> {2013, 12, 27}, 
        "open" -> 27.3698|>, <|"company" -> "GE", 
        "date" -> {2013, 12, 30}, 
        "open" -> 27.3708|>, <|"company" -> "GE", 
        "date" -> {2013, 12, 31}, "open" -> 27.4322|>}|>|>, 
 2014 -> <|1 -> <|"AAPL" -> {<|"company" -> "AAPL", 
        "date" -> {2014, 1, 2}, 
        "open" -> 78.4701|>, <|"company" -> "AAPL", 
        "date" -> {2014, 1, 3}, "open" -> 78.0778|>}, 
     "MSFT" -> {<|"company" -> "MSFT", "date" -> {2014, 1, 2}, 
        "open" -> 36.8173|>, <|"company" -> "MSFT", 
        "date" -> {2014, 1, 3}, "open" -> 36.6658|>}, 
     "GE" -> {<|"company" -> "GE", "date" -> {2014, 1, 2}, 
        "open" -> 27.394|>, <|"company" -> "GE", 
        "date" -> {2014, 1, 3}, "open" -> 27.0593|>}|>|>|> *);
        
(* NOW TO MAKE QUERY INTO THE NESTED ASSOCIATION *);
query[{}] = Identity; (*not necessary to add this *)
query[specs: {(_List|All)..}]:=Composition[Map[query[Rest@specs]],With[{curr = First@specs}, If[curr===All, # &, Part[#,Key/@curr]&]]]; 

q = query[{{2013}, All, {"AAPL", "MSFT"}}];
q[nested]

(* <|2013 -> <|12 -> <|"AAPL" -> {<|"company" -> "AAPL", "date" -> {2013, 12, 26}, "open" -> 80.2231|>, 
<|"company" -> "AAPL", "date" -> {2013, 12, 27}, "open" -> 79.6268|>, 
<|"company" -> "AAPL", "date" -> {2013, 12, 30}, "open" -> 78.7252|>,
<|"company" -> "AAPL", "date" -> {2013, 12, 31}, "open" -> 78.2626|>}, 
"MSFT" -> {<|"company" -> "MSFT", "date" -> {2013, 12, 26}, "open" -> 36.6635|>,
<|"company" -> "MSFT", "date" -> {2013, 12, 27}, "open" -> 37.0358|>,
<|"company" -> "MSFT", "date" -> {2013, 12, 30}, "open" -> 36.681|>,
<|"company" -> "MSFT", "date" -> {2013, 12, 31}, "open" -> 36.8601|>}|>|>|> *)





(* ---------------------------------- MEMOIZATION WITH PURE FUNCTIONS --------------------------- *)

SetAttributes[makeMemoPureFunc,HoldFirst];
makeMemoPureFunc[body_,start_: <||>]:= Module[{assoc = start},
    Function[
         If[KeyExistsQ[assoc, #], assoc[#], assoc[#] = body]
        ]
    ];
    
ff = makeMemoPureFunc[If[#>0, 1, 2]]
(* If[KeyExistsQ[fn$11658, #1], fn$11658[#1], 
  fn$11658[#1] = If[#1 > 0, 1, 2]] & *)
  
{ff[0], ff[1]}
(* {2,1} *)

OwnValues[fn$11658] (* values are garbage-collected at the end of execution. So we can access stored values using OwnValues *)
(* {HoldPattern[fn$11658] :> <|0 -> 2, 1 -> 1|>} *)

makeMemoPureFunc[#0[# - 1] + #0[# - 2], <|0 -> 1, 1 -> 1|>] (* here we generate the first 30 fibonacci numbers in a fast way. 
thanks to Memoization. #0 is calling the function recursively after we define the function body. Neat trick ! *)


(* lets make a cached version of a memoized function *)

assocShrink[a_Association, cacheLimit_] /; Length[a] > cacheLimit := 
  Drop[a, Length[a] - cacheLimit];
assocShrink[a_Association, _] := a;

SetAttributes[cachedMemoPureFunc, HoldFirst];
cachedMemoPureFunc[body_, start_: <||>, cacheLimit_: Infinity] := 
 Module[{fn = start},
  Function[
   If[
    KeyExistsQ[fn, #], fn[#], fn = assocShrink[fn, cacheLimit];
    fn[#] = body
    ]
   ]
  ];
  
  f = cachedMemoPureFunc[#0[# - 1] + #0[# - 2], <|0 -> 1, 1 -> 1|>];
  f/@ Range[500] // Short
  (* {"1", "2", <<497>>, "225591516161936330872512695036072072046011324913758190588638866418474627738686883405015987052796968498626"} *)
 



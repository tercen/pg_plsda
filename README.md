# pg_plsda


```
Barcode xxx zzz yyy
Treatment A  B   C
ID
gene1	100 200 300
gene2	10  20  30
gene3	1   2   3

DATA TABLE
rowSeq colSeq value treatment ID    Barcode QuantitationType
1       1     100    blue     gene1 xxxx    median_signal
1       2     200    red      gene1 zzzz

META DATA
factorName type
treatment  Color
rowSeq     rowSeq
colSeq     colSeq
value      value
ID         Spot
Barcode    Array


var types

Array
Spot
Color
rowSeq
colSeq
IsOutlier
QuantitationType
value

[
{"name": "rowSeq",
 "type": "rowSeq",
 "data": [1,1,2,2]
},
{"name": "colSeq",
 "type": "colSeq",
 "data": [1,2,1,2]
},
{"name": "treatment",
 "type": "Color",
 "data": [0,1,2,3]
},
{"name": "ID",
 "type": "Spot",
 "data": [gene0,gene0,gene1,gene1]
},
{"name": "Barcode",
 "type": "Array",
 "data": ["xxx","yyy","xxx","yyy"]
},
{"name": "value",
 "type": "value",
 "data": [12,1212,12,1]
}

]

```
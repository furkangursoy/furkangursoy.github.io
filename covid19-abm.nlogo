;extensions [nw]


globals[n]

breed [people person]
breed [houses house]
breed [churches church]
breed [schools school]
breed [cafes cafe]
breed [workplaces workplace]
breed [buses bus]


people-own[days recovered severe hospitalized infected]





to SETUP
  ca
  set n 1000

  ask patches [
    set pcolor white
  ]

  set-default-shape houses "house efficiency"
  set-default-shape churches "cross"
  set-default-shape cafes "food"
  set-default-shape workplaces "factory"
  set-default-shape buses "bus"
  set-default-shape people "person"
  set-default-shape schools "house ranch"
  set-default-shape links "a"


  create-people n
  [
    set days 0
    set recovered 0
    set infected 0
    set severe 0
    set hospitalized 0
    set size 4
    set color 62
    setxy random-xcor random-ycor
  ]

  create-houses 333
  [
    set size 6
    set color 1
    setxy random-xcor random-ycor
  ]

  create-churches 1
  [
    set size 15
    set color black
    setxy random-xcor random-ycor
  ]

  create-schools 2
  [
    set size 15
    set color 101
    setxy random-xcor random-ycor
  ]

  create-cafes 5
  [
    set size 15
    set color 21
    setxy random-xcor random-ycor
  ]

  create-workplaces 10
  [
    set size 15
    set color 31
    setxy random-xcor random-ycor
  ]

  create-buses 15
  [
    set size 6
    set color 122
    setxy random-xcor random-ycor
  ]


  ask people [
    create-link-with one-of other houses with [count link-neighbors < 6]
   ]

  ask n-of  worship-goers people [
    create-link-with one-of other churches
   ]

  ask n-of  school-goers people [
    create-link-with one-of other schools
   ]

  ask n-of  cafe-goers people [
    create-link-with one-of other cafes
   ]

  ask n-of  office-goers people [
    create-link-with one-of other workplaces
   ]

  ask n-of  bus-takers people [
    create-link-with one-of other buses
   ]




  repeat 50 [ layout-spring people links 0.2 5 1]


  ask n-of 2 people [
    set infected 1
    set color orange
  ]

  ;nw:set-context turtles links

  reset-ticks
end


to go
  if ticks = 365 ;; simulation runs for 365 days
  [
    stop
  ]

  if not Schools? [
    ask schools [
      die
    ]
  ]

  if not Churches? [
    ask churches [
      die
    ]
  ]

  if not Workplaces? [
    ask workplaces [
      die
    ]
  ]

  if not Cafes? [
    ask cafes [
      die
    ]
  ]

  if not Buses? [
    ask buses [
      die
    ]
  ]

  ; increase number of days spent infected
  ask people with [infected = 1] [
    set days  days + 1
  ]


  ; set if it's severe or not on the 21st day
  ask people with [days = 21] [
    if random 101 < severe-case-ratio
    [
      set severe 1
      set color red
    ]
  ]


  ; hospitalize severe people as long as capacity allows
  let idle-capacity hospital-capacity - count(people with [hospitalized = 1])
  let severe-people count(people with [severe = 1])
  let tobehospitalized min (list idle-capacity severe-people)
  ask max-n-of tobehospitalized people with [severe = 1] [days] ; hospitalize those who are severe and have the virus for longer time
  [
      set hospitalized  1
      set color blue
   ]


  ; spread the disease
  let sus1 nobody ;this is the first-order neighbors i.e., the relevant house and common places
  let sus nobody ;this is the people who share the same house or common places
  ask people with [infected = 1 and severe = 0] [
      set sus1 link-neighbors
      ;nw:turtles-in-radius 2
  ]

  ask sus1 [
    set sus link-neighbors
  ]

  if sus != nobody  [
    ask sus [
      if breed = people [
        if random 100 < transmission-probability [
          set infected 1
          set color orange
        ]

      ]
    ]
  ]

  ask people with [days = 28 and severe = 1] [

    ifelse hospitalized = 1
    [
       ifelse random 101 < death-probability-at-hospital-for-severe-cases
      [

        die

      ]
      [
        set color yellow
        set recovered 1
        set infected 0
        set severe 0
        set hospitalized 0
      ]

    ]

    [
       ifelse random 101 < death-probability-at-home-for-severe-cases
      [
        show death-probability-at-home-for-severe-cases
        die
      ]
      [
        set color yellow
        set recovered 1
        set infected 0
        set severe 0
      ]

    ]

  ]


  tick
end
@#$#@#$#@
GRAPHICS-WINDOW
487
13
1484
463
-1
-1
3.652
1
10
1
1
1
0
0
0
1
0
270
0
120
0
0
1
ticks
30.0

SLIDER
186
451
349
484
transmission-probability
transmission-probability
0
40
20.0
1
1
%
HORIZONTAL

SLIDER
184
524
453
557
death-probability-at-hospital-for-severe-cases
death-probability-at-hospital-for-severe-cases
0
100
33.0
1
1
%
HORIZONTAL

SLIDER
184
560
453
593
death-probability-at-home-for-severe-cases
death-probability-at-home-for-severe-cases
0
100
75.0
1
1
%
HORIZONTAL

BUTTON
21
635
162
668
CREATE THE TOWN
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
190
636
301
669
PASS ONE DAY
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
1349
495
1460
540
Dead (%)
(n - count(people) ) / 10
17
1
11

MONITOR
1143
496
1252
541
Living (%)
count(people) / 10
17
1
11

MONITOR
1357
548
1455
593
Recovered (%)
count(people with [recovered = 1]) / 10
17
1
11

BUTTON
353
637
469
670
Simulate until Day 365
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
184
486
350
519
severe-case-ratio
severe-case-ratio
0
30
20.0
1
1
%
HORIZONTAL

SLIDER
186
415
350
448
hospital-capacity
hospital-capacity
0
50
5.0
1
1
person
HORIZONTAL

MONITOR
1266
548
1352
593
Infected (%)
count(people with [infected = 1]) / 10
17
1
11

MONITOR
1141
548
1260
593
Never-got-sick (%)
count(people with [recovered = 0 and infected = 0]) / 10
17
1
11

MONITOR
1213
599
1328
644
Severe-at-home (%)
(count(people with [severe = 1 and hospitalized = 0]) ) / 10
17
1
11

MONITOR
1141
599
1209
644
Severe (%)
count(people with [severe = 1]) / 10
17
1
11

MONITOR
1332
598
1457
643
Severe-at-hospital (%)
count(people with [hospitalized = 1]) / 10
17
1
11

TEXTBOX
11
37
478
352
2 people from a town of 1000 people returns from a trip. Unfortunately, they were infected with the virus SARS-CoV-2 and they did not know that. \n\n- Each people lives with 2 others on average. Moreover, there are common places, specifically 2 schools, a place of worship, 5 cafes/restaurants, 10 workplaces, and 15 buses in the town. Specified numbers of people are associated with each other them and use/visit them each day.\n\n- Eacy day, an infected (but not severely-ill) person can infect those who live in the same house or those who share a common place, according to the transmission-probability.\n\n- On 21st day of infection, a person becomes severely ill according to the severe-case-ratio.\n\n- Each day, severely-ill people are hospitalized as long as the hospital-capacity allows.\n\n- On 28th day of infection, a severe people dies or recovers according to death probabilities. A recovered person is assumed to earn immunity.\n\n- You can close down common facilities to prevent spreading.
12
0.0
1

PLOT
489
472
1114
668
Infected & Severe &  Recovered
Days
Number
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -955883 true "" "plot count people with [infected = 1]"
"pen-1" 1.0 0 -2674135 true "" "plot count people with [severe = 1]"
"pen-2" 1.0 0 -1184463 true "" "plot count(people with [recovered = 1])"

SLIDER
19
450
164
483
worship-goers
worship-goers
0
200
100.0
1
1
person
HORIZONTAL

SLIDER
19
560
165
593
cafe-goers
cafe-goers
0
200
100.0
1
1
person
HORIZONTAL

SLIDER
19
486
164
519
office-goers
office-goers
0
500
250.0
1
1
person
HORIZONTAL

SLIDER
19
523
165
556
bus-takers
bus-takers
0
300
150.0
1
1
person
HORIZONTAL

SLIDER
18
415
164
448
school-goers
school-goers
0
400
200.0
1
1
person
HORIZONTAL

TEXTBOX
10
10
249
60
COVID SIMULATION
20
0.0
1

TEXTBOX
188
600
467
645
The above parameters can be changed both BEFORE and DURING the simulation.
11
0.0
1

SWITCH
361
411
455
444
Schools?
Schools?
0
1
-1000

TEXTBOX
17
600
174
642
The above parameters can be changed BEFORE town creation.
11
0.0
1

TEXTBOX
168
398
183
680
_____________________________________________
10
0.0
1

SWITCH
360
373
458
406
Churches?
Churches?
0
1
-1000

SWITCH
350
334
458
367
Workplaces?
Workplaces?
0
1
-1000

SWITCH
362
449
455
482
Cafes?
Cafes?
0
1
-1000

SWITCH
363
486
456
519
Buses?
Buses?
0
1
-1000

TEXTBOX
237
362
359
412
ps. once you close a common place, you cannot reopen it.
11
0.0
1

TEXTBOX
27
363
286
425
PLAYGROUND
29
103.0
1

MONITOR
303
629
353
674
Day
ticks
17
1
11

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

building store
false
0
Rectangle -7500403 true true 30 45 45 240
Rectangle -16777216 false false 30 45 45 165
Rectangle -7500403 true true 15 165 285 255
Rectangle -16777216 true false 120 195 180 255
Line -7500403 true 150 195 150 255
Rectangle -16777216 true false 30 180 105 240
Rectangle -16777216 true false 195 180 270 240
Line -16777216 false 0 165 300 165
Polygon -7500403 true true 0 165 45 135 60 90 240 90 255 135 300 165
Rectangle -7500403 true true 0 0 75 45
Rectangle -16777216 false false 0 0 75 45

bus
false
0
Polygon -7500403 true true 15 206 15 150 15 120 30 105 270 105 285 120 285 135 285 206 270 210 30 210
Rectangle -16777216 true false 36 126 231 159
Line -7500403 false 60 135 60 165
Line -7500403 false 60 120 60 165
Line -7500403 false 90 120 90 165
Line -7500403 false 120 120 120 165
Line -7500403 false 150 120 150 165
Line -7500403 false 180 120 180 165
Line -7500403 false 210 120 210 165
Line -7500403 false 240 135 240 165
Rectangle -16777216 true false 15 174 285 182
Circle -16777216 true false 48 187 42
Rectangle -16777216 true false 240 127 276 205
Circle -16777216 true false 195 187 42
Line -7500403 false 257 120 257 207

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

computer workstation
false
0
Rectangle -7500403 true true 60 45 240 180
Polygon -7500403 true true 90 180 105 195 135 195 135 210 165 210 165 195 195 195 210 180
Rectangle -16777216 true false 75 60 225 165
Rectangle -7500403 true true 45 210 255 255
Rectangle -10899396 true false 249 223 237 217
Line -16777216 false 60 225 120 225

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cross
false
0
Rectangle -7500403 true true 150 30 150 150
Rectangle -7500403 true true 150 15 150 210
Rectangle -7500403 true true 135 15 165 270
Rectangle -7500403 true true 75 90 225 120

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

factory
false
0
Rectangle -7500403 true true 76 194 285 270
Rectangle -7500403 true true 36 95 59 231
Rectangle -16777216 true false 90 210 270 240
Line -7500403 true 90 195 90 255
Line -7500403 true 120 195 120 255
Line -7500403 true 150 195 150 240
Line -7500403 true 180 195 180 255
Line -7500403 true 210 210 210 240
Line -7500403 true 240 210 240 240
Line -7500403 true 90 225 270 225
Circle -1 true false 37 73 32
Circle -1 true false 55 38 54
Circle -1 true false 96 21 42
Circle -1 true false 105 40 32
Circle -1 true false 129 19 42
Rectangle -7500403 true true 14 228 78 270

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

food
false
0
Polygon -7500403 true true 30 105 45 255 105 255 120 105
Rectangle -7500403 true true 15 90 135 105
Polygon -7500403 true true 75 90 105 15 120 15 90 90
Polygon -7500403 true true 135 225 150 240 195 255 225 255 270 240 285 225 150 225
Polygon -7500403 true true 135 180 150 165 195 150 225 150 270 165 285 180 150 180
Rectangle -7500403 true true 135 195 285 210

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

house efficiency
false
0
Rectangle -7500403 true true 180 90 195 195
Rectangle -7500403 true true 90 165 210 255
Rectangle -16777216 true false 165 195 195 255
Rectangle -16777216 true false 105 202 135 240
Polygon -7500403 true true 225 165 75 165 150 90
Line -16777216 false 75 165 225 165

house ranch
false
0
Rectangle -7500403 true true 270 120 285 255
Rectangle -7500403 true true 15 180 270 255
Polygon -7500403 true true 0 180 300 180 240 135 60 135 0 180
Rectangle -16777216 true false 120 195 180 255
Line -7500403 true 150 195 150 255
Rectangle -16777216 true false 45 195 105 240
Rectangle -16777216 true false 195 195 255 240
Line -7500403 true 75 195 75 240
Line -7500403 true 225 195 225 240
Line -16777216 false 270 180 270 255
Line -16777216 false 0 180 300 180

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
1.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

a
0.9
-0.2 0 0.0 1.0
0.0 1 2.0 2.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@

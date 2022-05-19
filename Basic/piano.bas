  5 s=54272
  10 forl=stos+24:pokel,0:next
  15 pokes+3,8:pokes+2,0
  20 pokes+5,9:pokes+6,0: rem A=0;D=9;S=0;R=0
  30 pokes+24,15
  40 readhf,lf,dr
  50 ifhf<0thenend
  60 pokes+1,hf:pokes,lf
  70 pokes+4,65
  80 fort=1todr:next
  90 pokes+4,64:fort=1to50:next
  100 goto40
  110 data25,177,250,28,214,250
  120 data25,177,250,25,177,250
  130 data25,177,125,28,214,125
  140 data32,94,750,25,177,250
  150 data28,214,250,19,63,250
  160 data19,63,250,19,63,250
  170 data21,154,63,24,63,63
  180 data25,177,250,24,63,125
  190 data19,63,250,-1,-1,-1

      
    
    
    
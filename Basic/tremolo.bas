  10 s=54272
  20 forl=0to24:pokes+l,0:next
  30 pokes+14,5
  40 pokes+18,16
  50 pokes+3,1
  60 pokes+24,143
  70 pokes+6,240
  80 pokes+4,65
  90 fr=5389
  100 fort=1to200
  110 fq=fr+peek(s+27)*3.5
  120 hf=int(fq/256):lf=fq-hf*256
  130 pokes+0,lf:pokes+1,hf
  140 next
  150 pokes+24,0
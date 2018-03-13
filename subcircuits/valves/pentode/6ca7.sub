*-----------------------------------------------------------------------
* Filename:		6ca7s.inc  19/5/97  V1
* Simulator:		Spice 3f4
* Device type:		Power pentode
* Device model:		6CA7/EL34
*
* Author:		Duncan Munro
* Date:			19/5/97
* Copyright:		(C)1997-2000 Duncan Amplification
* 
* The following parameters are not modelled:
*
*   (1) Heater
*   (2) Grid current is an approximation
*
* Please note that this model is provided "as is" and
* no warranty is provided in respect of its suitability
* for any application.
*
* This model is provided for educational and non-profit use.
*
* Email queries to postmaster@duncanamps.com
*
* Pins   A  Anode
*        S  Screen
*        G  Grid
*        K  Cathode
*
*-----------------------------------------------------------------------

.SUBCKT 6CA7 A S G K
*
* Calculate contribution to cathode current
*
Bat	at  0	V=0.636*ATAN(V(A,K)/23)
Bgs	gs  0	V=URAMP(V(S,K)/9.3+V(G,K)*0.95)
Bgs2	gs2 0	V=V(gs)^1.5
Bcath	cc  0	V=V(gs2)*V(at)
*
* Calculate anode current
*
Ba	A   K	I=1.86E-3*V(cc)
*
* Calculate screen current
*
Bscrn	sc  0	V=V(gs2)*(1.1-V(at))
Bs	S   K	I=1.518E-3*V(sc)
*
* Grid current (approximation - does not model low va/vs)
*
Bg	G   K	I=(URAMP(V(G,K)+1)^1.5)*50E-6
*
* Capacitances
*
Cg1	G	K	15.4p
Cak	A	K	8.4p
Cg1a	G	A	1.1p

.ENDS 

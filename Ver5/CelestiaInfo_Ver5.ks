//Celestia Setup Ver5
//Script Ver1

//-------------------------------------------------------------------

//Landing Zone Info (List is in "Library_Ver5")
//LZ[0(Ground Pad) or 1(ASDS)][LZ list number]

//LZ list
//Ground Pad (0)
//0: Triple Pad Side 1 (M)
//1: Triple Pad Side 2 (M)
//2: Triple Pad Center (S)
//3: Main Pad (L)
//4: Double Pad 1 (M)
//5: Double Pad 2 (M)

//ASDS (1)
//0: Of Course I Still Love You

//Expendable Booster
//Space

//-------------------------------------------------------------------

//Main Setting
//Mission Name
set MissionName to "Celestia Test Flight".

//Countdown Time (s)
set CountdownT to 10.

//Time needed for Ignition (s)
set IgnitionT to 3.

//Gravity turn angle
set GTAngle to 15.

//Fairing Decouple Altitude (m)
set FairingAlt to 60000.

//-------------------------------------------------------------------

//Orbital Info
//Pariking Orbit (m)
set POrbit to 150000.

//Target Apoapsis (m)
set tgAp to 150000.
//Target Periapsis (m)
set tgPe to 130000.
//Target Inclination
set tgInc to 0.
//Target longitude of Ascending node
set tgLan to 0.
//Target argument of Periapsis
set tgAop to 0.

//-------------------------------------------------------------------

//Celestia Setting

//-------------------------------------------------------------------

//Terrestia Booster Setting
//Ship Radar (m)
set exAlt_T to 59.2639.

//Boostback angle
set bbAngle_T to 165.

//Landing Zone
set LZ_T to LZlist[1][0].

//-------------------------------------------------------------------

//Static Fire Test
//Static Fire Time (s)
set SFTime to 15.

//Static Fire Throttle (%)
set SFThrottle to 100.
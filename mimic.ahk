#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

Gui +LastFound +OwnDialogs +AlwaysOnTop ;keeps gui windows on top

;INPUT MIMIC 1.3
;functions: left/right mouse clicking, click and drag, A-Z, 0-9

global function:=[]
global parameter:=[]
global recordingmode=1
randomness:=1 ;keep this (1) to lessen the risk of being banned
if(randomness=1){
	global timemin=1000
	global timemax=2000
	global xmin=-5 ;these can be changed to increase 
	global xmax= 5 ;or decrease cursor deviation 
	global ymin=-5 ;depending on how precise 
	global ymax= 5 ;the click needs to be
}
if(randomness=0){
	global timemin=0
	global timemax=0
	global xmin=0
	global xmax=0
	global ymin=0
	global ymax=0
}

MsgBox, 0, Preparing to Record, After pressing OK, recording will start after 2 seconds at the tone. Press F7 to stop recording.
Sleep 2000
recordingmode=0 
;SoundPlay,%A_WinDir%\Media\ding.wav,
tooltip,Recording
global clock:=a_tickcount

Loop{
	Input,key,l1 v
	if(recordingmode=1){ 
		DelayEnd.add()
		break
	}
	KeyPress.add(key)
}

tooltip, ;hides the previous tooltip
InputBox, loops, Recording Stopped, Play how many times? (Recommended <1500),,,,,,,,100
MsgBox, 0, Preparing for Playback, After pressing OK, playback will start after 2 seconds. Make sure the correct window is active.
Sleep 2000

Loop %loops%{
	i=1
	if(loops>0){
		count:=loops-A_Index+1
		tooltip,Remaining:%count%,100,100
	}
	Loop % function.length(){
		function[i].execute(parameter[i])
		i++
	}
}

tooltip, ;hides the previous tooltip
SoundPlay,%A_WinDir%\Media\tada.wav,
MsgBox, 4, Waiting for response..., Script finish. Do you want to start again?. 
IfMsgBox Yes
	Reload
else IfMsgBox No
	ExitApp,0 

class MouseClick{
	execute(m){	;1=button,2=xcoord,3=ycoord,4=direction (1=down 2=up)
		MouseMove,(m[2]+rand(xmin,xmax)),(m[3]+rand(ymin,ymax))
		;MouseGetPos,x1,x2
		Sleep 500
		if(m[1]=1 && m[4]=1)
			Click,down
		if(m[1]=2 && m[4]=1)
			Click,down,right
		if(m[1]=1 && m[4]=2)
			Click,up
		if(m[1]=2 && m[4]=2)
			Click,up,right
	}
	add(b,d){
		if(recordingmode=0){
			Delay.add()
			function.push(MouseClick)	
			MouseGetPos,x0,y0
			m%n%:=[b,x0,y0,d] ;button, xpos, ypos, button direction
			parameter.push(m%n%)
			n++
			return
		}
	}
}

class KeyPress{
	execute(k){ 
		Send {%k% down}
		Sleep 200
		Send {%k% up}
	}
	add(k){
		if(recordingmode=0){
			Delay.add()
			function.push(KeyPress)	;parameter later should be an array [key,direction]
			parameter.push(k)  ;to enable holding down keys not sure how to do this yet
			return
		}
	}
}

class modifierKey{ ;shift works, ctrl doesn't work, not sure if Alt works
	execute(h){
		temp=h[1]
		if(h[2]=1){
			Send {%temp% down}
		}
		if(h[2]=2){
			Send {%temp% up}
		}
	}
	add(k,d){
		if(recordingmode=0){
			Delay.add()
			function.push(modifierKey)
			h%i% := [k,d] ;[key, button direction]
			parameter.push(h%n%)
			i++
		}	return
	}
}

class Delay{
	execute(t){
		bedtime:=t+rand(timemin,timemax)
		;tooltip, sleeping for %bedtime% ;for testing purposes
		Sleep (bedtime)		
	}	
	add(){
		function.push(Delay)
		timer:=a_tickcount-clock
		parameter.push(timer)
		;tooltip,Added a %timer% ms delay ;for testing purposes
		clock:=a_tickcount
		return
	}
}
class DelayEnd{
	execute(t){
		bedtime:=t+rand(0,500)
		;tooltip, sleeping for %bedtime% ;for testing purposes
		Sleep (bedtime)		
	}	
	add(){
		function.push(DelayEnd)
		timer:=a_tickcount-clock
		parameter.push(timer)
		;tooltip,Added a %timer% ms delay ;for testing purposes
		clock:=a_tickcount
		return
	}
}

Rand(a=0.0,b=1) {
   IfEqual,a,,Random,,% r := b = 1 ? Rand(0,0xFFFFFFFF) : b
   Else Random,r,a,b
   Return r
}

;override controls, change these if you want
F7::recordingmode:=1
F8::Pause
F9::Reload ;restarts the script
F10::ExitApp,1 ;force ends the script

;don't change these
~lbutton::MouseClick.add(1,1)
~rbutton::MouseClick.add(2,1)
~lbutton up::MouseClick.add(1,2)
~rbutton up::MouseClick.add(2,2)
~space::KeyPress.add("space")
~Alt::modifierKey.add("Alt",1)
~Alt up::modifierKey.add("Alt",2)
~Shift::modifierKey.add("Shift",1)
~Shift up::modifierKey.add("Shift",2)
~Ctrl::modifierKey.add("Ctrl",1)
~Ctrl up::modifierKey.add("Ctrl",2)


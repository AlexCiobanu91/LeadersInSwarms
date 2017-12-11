#pragma once

class WindowListener {
public:
	WindowListener() {}
	virtual ~WindowListener() {}

	//------------------- functii ce tin cadrul curent
	//functie chemata inainte de inceperea cadrului curent (adica inainte de a incepe procesul de afisare)
	virtual void NotifyBeginFrame() {}
	//functie de afisare, chemata inainte afisarea efectiva (swapBuffers)
	virtual void NotifyDisplayFrame() {}
	//functie chemata dupa sfarsirea procesului de afisare pe CPU
	virtual void NotifyEndFrame() {}

	//------------------- reshape - se apealeaza atunci cand ecranul este 
	virtual void NotifyReshape(int width, int height, int previos_width, int previous_height) {}

	//------------------- functii de input
	//functie chemata cand e apasata o tasta
	virtual void NotifyKeyPressed(unsigned char key_pressed, int mouse_x, int mouse_y) {}
	//functie chemata cand se termina apasarea unei taste
	virtual void NotifyKeyReleased(unsigned char key_released, int mouse_x, int mouse_y) {}
	//functie chemata cand o tasta speciala e apasata (up down, left right, F1-12, etc)
	virtual void NotifySpecialKeyPressed(int key_pressed, int mouse_x, int mouse_y) {}
	//functie chemata cand ose termina apsarea unei taste speciale (up down, left right, F1-12, etc)
	virtual void NotifySpecialKeyReleased(int key_released, int mouse_x, int mouse_y) {}
	//functie chemata cand se face mouse drag
	virtual void NotifyMouseDrag(int mouse_x, int mouse_y) {}
	//functie chemata cand mouse-ul se misca
	virtual void NotifyMouseMove(int mouse_x, int mouse_y) {}
	//functie chemata cand un button de mouse e apasat
	virtual void NotifyMouseClick(int button, int state, int mouse_x, int mouse_y) {}
	//functie chemata cand se face scroll cu mouse-ul.
	virtual void NotifyMouseScroll(int wheel, int direction, int mouse_x, int mouse_y) {}
};
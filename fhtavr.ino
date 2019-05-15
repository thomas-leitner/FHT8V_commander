extern "C" {
  int fhtsetup();
  int fhtloop();
}

void setup() {   
  fhtsetup();
  //temp_init();
}

void loop() {
 
  fhtloop();
}

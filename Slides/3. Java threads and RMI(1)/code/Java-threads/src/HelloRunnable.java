public class runClass {

    public void run() {
        System.out.println("Hello from as thread!");
    }
	
}

public class HelloRunnable implements Runnable {

    public void run() {
        System.out.println("Hello from as thread!");
    }

    public static void main(String args[]) throws Exception {
    	for (int i = 0; i < 5; i++) {
    		
    		Thread t = new Thread();
        	t.start();
        	t.join();	
		}
    
    }
}



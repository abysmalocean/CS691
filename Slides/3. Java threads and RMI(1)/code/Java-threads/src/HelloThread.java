public class HelloThread extends Thread {

    public void run() {
        System.out.println("Hello from as thread!");
    }

    public static void main(String args[]) throws Exception {
    	HelloThread t = new HelloThread();
    	t.start();
    	t.join();
    }
}

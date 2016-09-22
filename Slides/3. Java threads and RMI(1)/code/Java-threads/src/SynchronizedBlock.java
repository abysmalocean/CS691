public class SynchronizedBlock {
	
	public static class SynchronizedCounter {
		private int c = 0;

		public void increment() {
			synchronized(this) {
				c++;
			}
		}

		public int value() {
			return c;
		}
	}

	private static class MyThread extends Thread {

		SynchronizedCounter counter;

		public MyThread (SynchronizedCounter counter) {
			this.counter = counter;
		}

		public void run() {
			for(int i = 0; i < 1000; i++)
				counter.increment();
		}
	}

	public static void main(String args[]) throws Exception { 

		SynchronizedCounter counter = new SynchronizedCounter();
		
		MyThread[] threads = new MyThread[10];
		
		for(int i = 0; i < 10; i++)
			threads[i] = new MyThread(counter);
		
		for(int i = 0; i < 10; i++)
			threads[i].start();
		
		for(int i = 0; i < 10; i++)
			threads[i].join();
		
		System.out.println(counter.value());	
	}
}
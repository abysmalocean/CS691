package experiments;

import evolutionary.SSGA;

public class RunAlgorithm {

	public static void main(String[] args) {
		
		int populationSize = 100;
		int SSGAIterations = 10000;
		int dimensions = 10;
		
		SSGA algorithm = new SSGA(123456, populationSize, dimensions);
		
		algorithm.initializePopulation();
		
		algorithm.runSSGA(SSGAIterations);
		
		System.out.println("Final best solution " + algorithm.getPopulation().get(0));
	}
}

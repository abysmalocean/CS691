package evolutionary;

import java.util.Random;

public class CrossoverBLX {

	private Random randGen;
	private double alpha;
	private double min;
	private double max;
	
	public CrossoverBLX(Random randGen, double alpha, double min, double max)
	{
		this.randGen = randGen;
		this.alpha = alpha;
		this.min = min;
		this.max = max;
	}
	
	public Individual cross(Individual p1, Individual p2)
	{
		double[] parent1 = p1.getGenotype();
		double[] parent2 = p2.getGenotype();
		
		int length = parent1.length;
		double[] child = new double[length];

		for(int i = 0; i < length; i++)
		{
			double left = Math.min(parent1[i], parent2[i]);
			double right = Math.max(parent1[i], parent2[i]);
			double width = (right - left) * alpha;

			left = Math.max(min, left - width);
			right= Math.min(max, right + width);

			child[i] = left + randGen.nextDouble() * (right - left);
		}

		return new Individual(child);
	}
}
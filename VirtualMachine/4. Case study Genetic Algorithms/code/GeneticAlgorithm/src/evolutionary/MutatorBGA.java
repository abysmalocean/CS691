package evolutionary;

import java.util.Random;

public class MutatorBGA {

	private Random randGen;
	private double mutationProbability;
	private double min;
	private double max;
	
	public MutatorBGA(Random randGen, double mutationProbability, double min, double max)
	{
		this.randGen = randGen;
		this.mutationProbability = mutationProbability;
		this.min = min;
		this.max = max;
	}
	
	public Individual mutate(Individual p)
	{
		double[] parent = p.getGenotype();
		double[] mutated = parent.clone();
		
		if(randGen.nextDouble() < mutationProbability)
		{
			int pos = randGen.nextInt(mutated.length);
			int num = 16;
		    double pai = 1.0d / num;
			double dif = 1.0d;
			double sum = 0;
			
			for (int i = 0; i < num; i++, dif/=2.0)
				if (randGen.nextDouble() < pai)
					sum += dif;
			
			if (sum != 0)
			{
				double range = 0.1 * (max - min);

				if (randGen.nextDouble() < 0.5) {
					double value = mutated[pos] + range * sum;
					mutated[pos] = Math.min(value, max);
				}
				else
				{
					double value = mutated[pos] - range * sum;
					mutated[pos] = Math.max(value, min);
				}
			}
		}
		
		return new Individual(mutated);
	}
}
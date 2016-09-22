package evolutionary;

import java.util.Comparator;
import java.util.List;

public class Evaluator {

	public Evaluator()
	{
		super();
	}

	public void evaluate(List<Individual> population) 
	{
		for(Individual individual : population)
			evaluate(individual);
	}

	public void evaluate(Individual individual) 
	{
		double[] genotype = individual.getGenotype();
		int dimensions = genotype.length;
		double fitness = 0;

		for(int i = 0; i < dimensions; i++)
			fitness += genotype[i] * genotype[i]; // minimizes the sum of x^2

		individual.setFitness(fitness);
	}

	public Comparator<Individual> getComparator() {
		return new Comparator<Individual> () {
			public int compare(Individual a, Individual b) {
				return a.getFitness() < b.getFitness() ? -1 : a.getFitness() > b.getFitness() ? 1 : 0;
			}
		};
	}
}
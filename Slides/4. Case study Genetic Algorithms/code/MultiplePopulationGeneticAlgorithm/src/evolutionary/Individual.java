package evolutionary;

import java.io.Serializable;
import java.util.Arrays;

public class Individual implements Serializable {
	
	private static final long serialVersionUID = 3212206983815081326L;
	
	private double[] genotype;
	private double fitness;
	
	public Individual()
	{
		super();
	}
	
	public Individual(double[] genotype)
	{
		this.genotype = genotype;
	}
	
	public Individual(double[] genotype, double fitness)
	{
		this.genotype = genotype;
		this.fitness = fitness;
	}
	
	public double[] getGenotype() {
		return genotype;
	}
	
	public double getFitness() {
		return fitness;
	}
	
	public void setGenotype(double[] genotype) {
		this.genotype = genotype;
	}
	
	public void setFitness(double fitness) {
		this.fitness = fitness;
	}
	
	@Override
	public boolean equals(Object other) {
		if(!(other instanceof Individual)) {
			return false;
		}
		else
		{
			double[] thisGenotype = getGenotype();
			double[] otherGenotype = ((Individual) other).getGenotype();
			
			int dimensions = thisGenotype.length;
			
			for(int i = 0; i < dimensions; i++)
				if(thisGenotype[i] != otherGenotype[i])
					return false;
			
			return true;
		}
	}
	
	@Override
	public String toString() {
		return "Individual: " + Arrays.toString(genotype) + "\t fitness: " + fitness;
	}
}

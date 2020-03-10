interface Item {
    id: string;
    state: string;
    district: string;
    population: number;
    website: string;
    geography: string;
    religion: string;
    pointsOfInterest: PointOfInterest;
  }

interface PointOfInterest extends Map<string, string> {
    title: string,
    content: string
}
  
  export default Item;
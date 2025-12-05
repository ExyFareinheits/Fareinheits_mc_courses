export interface Course {
  id: string;
  title: string;
  slug: string;
  description: string;
  shortDescription: string;
  price: number;
  currency: string;
  difficulty: 'beginner' | 'intermediate' | 'advanced';
  duration: string;
  topics: string[];
  whatYouLearn: string[];
  requirements: string[];
  purchaseLinks: {
    gumroad?: string;
    patreon?: string;
    kofi?: string;
  };
  format: string[];
  bonus?: string[];
}

export interface CourseModule {
  id: string;
  title: string;
  lessons: string[];
}

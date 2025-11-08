import { TestBed } from '@angular/core/testing';

import { Humeur } from './humeur';

describe('Humeur', () => {
  let service: Humeur;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(Humeur);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});

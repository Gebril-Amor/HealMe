import { ComponentFixture, TestBed } from '@angular/core/testing';
import { TherapistHomePage } from './therapist-home.page';

describe('TherapistHomePage', () => {
  let component: TherapistHomePage;
  let fixture: ComponentFixture<TherapistHomePage>;

  beforeEach(() => {
    fixture = TestBed.createComponent(TherapistHomePage);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});

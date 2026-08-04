import supertest, { Test, Response } from 'supertest';
import TestAgent from 'supertest/lib/agent';
import app from '@src/server';

import PersonaRepo from '@src/repos/Persona/sqlRepo';
import Person from '@src/models/Persona';
import HttpStatusCodes from '@src/constants/HttpStatusCodes';

import Paths from 'spec/support/Paths';
import apiCb from 'spec/support/apiCb';
import { TApiCb } from 'spec/types/misc';
import { IPersona } from '@src/Interface/Persona/PersonaInterface';

// Dummy users for GET req
const getDummyPersonas = (): IPersona[] => {
  return [
    Person.new(
      'PARQUE',
      'HOSPINAL',
      'JUAN MARTÍN',
      '61278643',
      '123456789',
      'juan@example.com',
      '123 Main St',
      '01',
      '987654321',
      '123',
      new Date('1990-01-01T00:00:00.000Z'),
      'M',
      'LIM',
      'LIM01',
      'LIM0101',
      true,
      '2023',
      'secreto',
      true,
      'Cerca del parque'
    ),
    Person.new(
      'ABAD',
      'PEÑA',
      'JOSE MANUEL',
      '77499259',
      '123456789',
      'jose@example.com',
      '456 Main St',
      '01',
      '987654321',
      '123',
      new Date('1991-01-01T00:00:00.000Z'),
      'M',
      'LIM',
      'LIM01',
      'LIM0101',
      true,
      '2023',
      'secreto',
      true,
      'Cerca del parque',
      'LIM01',
      'P2'
    ),
    Person.new(
      'ABASTOS',
      'FLOR',
      'JORGE JAIME',
      '71229399',
      '123456789',
      'jorge@example.com',
      '789 Main St',
      '01',
      '987654321',
      '123',
      new Date('1992-01-01T00:00:00.000Z'),
      'M',
      'LIM',
      'LIM01',
      'LIM0101',
      true,
      '2023',
      'secreto',
      true,
      'Cerca del parque',
      'LIM01',
      'P3'
    ),
  ];
};

describe('PersonaRouter', () => {
  let agent: TestAgent<Test>;
  let token: string;

  // Run before all tests
  beforeAll((done) => {
    supertest('http://localhost:3001')
      .post('/login-api')
      .send({ username: 'hrafael', password: 'syscolegio' })
      .end((err: Error | null, res: Response) => {
        if (err) {
          return done.fail(err);
        }
        token = (res.body as { token: string }).token;
        agent = supertest.agent(app);
        done();
      });
  });

  // Get all users
  describe(`"GET:${Paths.Persona.Get}"`, () => {
    // Setup API
    const api = (cb: TApiCb) => {
      if (!token) {
        throw new Error('Token is not defined');
      }
      agent
        .get(Paths.Persona.Get)
        .set('Authorization', `Bearer ${token}`)
        .end(apiCb(cb));
    };

    // Success
    it(
      'should return a JSON object with all the users and a status code ' +
        `of "${HttpStatusCodes.OK}" if the request was successful.`,
      (done) => {
        // Add spy
        const data = getDummyPersonas();
        spyOn(PersonaRepo, 'getAll').and.resolveTo(data);
        // Call API
        api((res) => {
          expect(res.status).toBe(HttpStatusCodes.OK);
          // Convert response dates to Date objects for comparison
          const responseBody = res.body as { people: IPersona[] };
          responseBody.people.forEach((person: IPersona) => {
            if (person.fechaNacimiento) {
              person.fechaNacimiento = new Date(person.fechaNacimiento);
            }
          });
          expect(responseBody).toEqual({ people: data });
          done();
        });
      }
    );
  });

  // Test add person
  describe(`"POST:${Paths.Persona.Add}"`, () => {
    const ERROR_MSG =
        'The following parameter was missing' + ' or invalid: "persona".',
      DUMMY_PERSONA = getDummyPersonas()[0];

    // Setup API
    const callApi = (persona: IPersona | null, cb: TApiCb) =>
      agent
        .post(Paths.Persona.Add)
        .set('Authorization', `Bearer ${token}`)
        .send({ persona })
        .end(apiCb(cb));

    // Test add user success
    it(
      `should return a status code of "${HttpStatusCodes.CREATED}" if the ` +
        'request was successful.',
      (done) => {
        // Spy
        spyOn(PersonaRepo, 'add').and.resolveTo({
          Result: 1,
          Message: 'Success',
        });
        // Call api
        callApi(DUMMY_PERSONA, (res) => {
          expect(res.status).toBe(HttpStatusCodes.CREATED);
          done();
        });
      }
    );

    // Missing id_distrito_vivienda param
    it(
      `should return a JSON object with an error message of "${ERROR_MSG}" ` +
        `and a status code of "${HttpStatusCodes.BAD_REQUEST}" ` +
        'if the id_distrito_vivienda ' +
        'param was missing.',
      (done) => {
        // Call api with missing id_distrito_vivienda
        const personaWithoutDistritoVivienda = { ...DUMMY_PERSONA };
        delete personaWithoutDistritoVivienda.id_distrito_vivienda;
        callApi(personaWithoutDistritoVivienda, (res) => {
          expect(res.status).toBe(HttpStatusCodes.BAD_REQUEST);
          expect(res.body.error).toBe(ERROR_MSG);
          done();
        });
      }
    );
  });
});

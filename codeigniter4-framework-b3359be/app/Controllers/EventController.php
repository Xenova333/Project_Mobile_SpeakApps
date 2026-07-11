<?php

namespace App\Controllers;

use App\Models\EventModel;
use CodeIgniter\RESTful\ResourceController;

class EventController extends ResourceController
{
    protected $modelName = 'App\Models\EventModel';
    protected $format    = 'json';

    private function setCorsHeaders(): void
    {
        $this->response->setHeader('Access-Control-Allow-Origin', '*');
        $this->response->setHeader('Access-Control-Allow-Headers', 'X-API-KEY, Origin, X-Requested-With, Content-Type, Accept, Access-Control-Request-Method, Authorization');
        $this->response->setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS, PUT, DELETE');
    }

    // GET /api/events
    public function index()
    {
        $this->setCorsHeaders();
        $events = $this->model->orderBy('event_date', 'ASC')->findAll();
        
        // Append full URL for image
        foreach ($events as &$event) {
            if (!empty($event['image'])) {
                $event['image'] = base_url('uploads/events/' . $event['image']);
            }
        }

        return $this->respond([
            'status' => 'success',
            'data'   => $events
        ]);
    }

    // POST /api/events
    public function createEvent()
    {
        $this->setCorsHeaders();
        if ($this->request->getMethod() === 'options') {
            return $this->response->setStatusCode(200);
        }

        $rules = [
            'title'       => 'required',
            'description' => 'required',
            'event_date'  => 'required',
            'event_link'  => 'permit_empty'
        ];

        if (!$this->validate($rules)) {
            return $this->fail($this->validator->getErrors());
        }

        $data = [
            'title'       => $this->request->getPost('title'),
            'description' => $this->request->getPost('description'),
            'event_date'  => $this->request->getPost('event_date'),
            'event_link'  => $this->request->getPost('event_link'),
        ];

        // Handle Image Upload
        $imageFile = $this->request->getFile('image');
        if ($imageFile) {
            if (!$imageFile->isValid()) {
                return $this->respond(['status' => 500, 'message' => 'File gambar tidak valid atau tidak terbaca di server'], 500);
            }
            if (!$imageFile->hasMoved()) {
                $newName = $imageFile->getRandomName();
                $imageFile->move(ROOTPATH . 'public/uploads/events', $newName);
                $data['image'] = $newName;
            }
        }

        if ($this->model->insert($data)) {
            $data['id'] = $this->model->getInsertID();
            if (isset($data['image'])) {
                $data['image'] = base_url('uploads/events/' . $data['image']);
            }
            return $this->respondCreated([
                'status'  => 'success',
                'message' => 'Event created successfully',
                'data'    => $data
            ]);
        }

        return $this->failServerError('Failed to create event');
    }

    // PUT /api/events/$id atau POST /api/events/$id (dengan _method=PUT)
    public function updateEvent($id = null)
    {
        $this->setCorsHeaders();
        if ($this->request->getMethod() === 'options') {
            return $this->response->setStatusCode(200);
        }

        $event = $this->model->find($id);
        if (!$event) {
            return $this->failNotFound('Event not found');
        }

        // Catch data from POST if multipart/form-data (when updating with file)
        // Or getJSON / getRawInput if it's application/json PUT
        $data = $this->request->getPost();
        if (empty($data)) {
            $data = $this->request->getJSON(true) ?? $this->request->getRawInput();
        }

        // Clean out any _method field
        if (isset($data['_method'])) {
            unset($data['_method']);
        }

        // Handle Image Upload if any
        $imageFile = $this->request->getFile('image');
        if ($imageFile) {
            if (!$imageFile->isValid()) {
                return $this->respond(['status' => 500, 'message' => 'File gambar tidak valid atau tidak terbaca di server'], 500);
            }
            if (!$imageFile->hasMoved()) {
                $newName = $imageFile->getRandomName();
                $imageFile->move(ROOTPATH . 'public/uploads/events', $newName);
                $data['image'] = $newName;
                
                // Delete old image if exists
                if (!empty($event['image']) && file_exists(ROOTPATH . 'public/uploads/events/' . $event['image'])) {
                    @unlink(ROOTPATH . 'public/uploads/events/' . $event['image']);
                }
            }
        }

        if (empty($data)) {
            return $this->fail('No data provided to update.');
        }

        if ($this->model->update($id, $data)) {
            return $this->respond([
                'status'  => 'success',
                'message' => 'Event updated successfully'
            ]);
        }

        return $this->failServerError('Failed to update event');
    }

    // DELETE /api/events/$id
    public function deleteEvent($id = null)
    {
        $this->setCorsHeaders();
        if ($this->request->getMethod() === 'options') {
            return $this->response->setStatusCode(200);
        }

        $event = $this->model->find($id);
        if (!$event) {
            return $this->failNotFound('Event not found');
        }

        if ($this->model->delete($id)) {
            // Delete image file if exists
            if (!empty($event['image']) && file_exists(FCPATH . 'uploads/events/' . $event['image'])) {
                @unlink(FCPATH . 'uploads/events/' . $event['image']);
            }

            return $this->respondDeleted([
                'status'  => 'success',
                'message' => 'Event deleted successfully'
            ]);
        }

        return $this->failServerError('Failed to delete event');
    }

    // POST /api/events/main/{id}
    public function setMainEvent($id = null)
    {
        $this->setCorsHeaders();
        if ($this->request->getMethod() === 'options') {
            return $this->response->setStatusCode(200);
        }

        $event = $this->model->find($id);
        if (!$event) {
            return $this->failNotFound('Event tidak ditemukan');
        }

        // 1. Set semua event menjadi bukan main event (is_main = 0)
        $this->model->where('id !=', $id)->set(['is_main' => 0])->update();
        
        // 2. Set event yang dipilih saat ini menjadi main event (is_main = 1)
        $updated = $this->model->update($id, ['is_main' => 1]);

        if ($updated) {
            return $this->respond(['status' => 'success', 'message' => 'Berhasil menjadikan sebagai Main Event']);
        } else {
            return $this->respond(['status' => 'error', 'message' => 'Gagal memperbarui status Main Event'], 400);
        }
    }

    // GET /api/events/main-active
    public function getMainEvent()
    {
        $this->setCorsHeaders();
        if ($this->request->getMethod() === 'options') {
            return $this->response->setStatusCode(200);
        }

        $mainEvent = $this->model->where('is_main', 1)->first();
        
        // Jika tidak ada yang ditandai is_main = 1, ambil event paling terbaru sebagai fallback
        if (!$mainEvent) {
            $mainEvent = $this->model->orderBy('id', 'DESC')->first();
        }
        
        if ($mainEvent) {
            // Pastikan path image dikirim dengan full base_url yang valid
            if (!empty($mainEvent['image'])) {
                $mainEvent['image'] = base_url('uploads/events/' . $mainEvent['image']);
            }
            return $this->respond($mainEvent);
        }
        return $this->failNotFound('Belum ada data event sama sekali');
    }
    // GET /api/events/month/(:num)
    public function getEventsByMonth($month = null)
    {
        $this->setCorsHeaders();
        if ($this->request->getMethod() === 'options') {
            return $this->response->setStatusCode(200);
        }

        if (!$month) {
            return $this->respond([], 200);
        }

        // Cari event berdasarkan bulan (event_date format YYYY-MM-DD)
        $events = $this->model->where('MONTH(event_date)', $month)->orderBy('event_date', 'ASC')->findAll();
        
        if (empty($events)) {
            // Cukup kirimkan HTTP 200 dengan array kosong (tanpa error 404/500)
            return $this->respond([
                'status' => 'success',
                'data'   => []
            ], 200);
        }
        
        // Append full URL for image
        foreach ($events as &$event) {
            if (!empty($event['image'])) {
                $event['image'] = base_url('uploads/events/' . $event['image']);
            }
        }

        return $this->respond([
            'status' => 'success',
            'data'   => $events
        ]);
    }
}

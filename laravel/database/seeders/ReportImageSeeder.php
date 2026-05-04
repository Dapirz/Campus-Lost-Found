<?php

namespace Database\Seeders;

use App\Models\Report;
use App\Models\ReportImage;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Storage;

class ReportImageSeeder extends Seeder
{
    /**
     * Seed the application's report images.
     */
    public function run(): void
    {
        $sampleImages = [
            'https://placehold.co/400x300/0052CC/white?text=Dompet',
            'https://placehold.co/400x300/0B7A75/white?text=Laptop',
            'https://placehold.co/400x300/475467/white?text=Kunci',
            'https://placehold.co/400x300/0052CC/white?text=KTM',
            'https://placehold.co/400x300/0B7A75/white?text=Earbuds',
        ];

        $disk = Storage::disk('public');
        $disk->makeDirectory('reports');

        foreach ($sampleImages as $index => $url) {
            $response = Http::timeout(30)
                ->retry(2, 500)
                ->get($url)
                ->throw();

            $disk->put('reports/dummy-'.($index + 1).'.jpg', $response->body());
        }

        ReportImage::query()->delete();

        $reports = Report::query()
            ->orderBy('created_at')
            ->orderBy('id')
            ->get();

        foreach ($reports as $index => $report) {
            $imageNumber = ($index % count($sampleImages)) + 1;
            $imagePath = 'reports/dummy-'.$imageNumber.'.jpg';

            ReportImage::query()->create([
                'report_id' => $report->id,
                'image_url' => $disk->url($imagePath),
                'created_at' => $report->created_at,
                'updated_at' => $report->created_at,
            ]);
        }
    }
}
